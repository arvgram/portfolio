from bottle import get, post, run, request, response
import sqlite3
import logging
from datetime import date
from urllib.parse import quote, unquote

db = sqlite3.connect("krusty_db.sqlite")
PORT = 8888

logger = logging.getLogger(__name__)
logger.setLevel(logging.WARNING)


@post('/reset')
def reset():
    c = db.cursor()
    to_shut_down = ['raw_materials_warehouse', "customers",
                    "recipes", "ingredients", "deliveries",
                    "pallets", 'ingredient_list', 'delivery_specs',
                    ]

    for table in to_shut_down:
        c.execute(
            f"""
            DELETE 
            FROM {table}
            """
        )

    db.commit()
    response.status = 205


@post('/customers')
def post_customer():
    body = request.json
    c = db.cursor()
    c.execute(
        """
        INSERT
        INTO customers(customer_name, customer_address)
        VALUES(?,?)
        """,
        [body['name'], body['address']]
    )
    db.commit()
    response.status = 201
    return {'location': '/customers/' + quote(body['name'])}


@get('/customers')
def get_customers():
    c = db.cursor()
    c.execute(
        """
        SELECT customer_name, customer_address
        FROM customers
        """
    )
    found = [{"name": name, "address": address}
             for name, address in c]
    response.status = 200
    return {"data": found}


@post('/ingredients')
def post_ingredient():
    rqb = request.json
    c = db.cursor()
    c.execute(
        """
        INSERT
        INTO ingredients(ingredient_name,unit)
        VALUES (?,?)
        """,
        [rqb['ingredient'], rqb['unit']]
    )
    c.execute(
        """
        SELECT unit
        FROM ingredients
        WHERE ingredient_name = ?
        """,
        [rqb['ingredient']]
    )
    c.execute(
       """
       INSERT
       INTO raw_materials_warehouse(ingredient_name, amount_stored)
       VALUES (?, 0)
       """,
       [rqb['ingredient']]
   )
    db.commit()
    response.status = 201

    return {"location": "/ingredients/" + quote(rqb['ingredient'])}


@post('/ingredients/<ingredient_name>/deliveries')
def post_delivery(ingredient_name):
    rqb = request.json
    c = db.cursor()
    # logger.warning(f'ingredient: {ingredient_name}, amount: {rqb["quantity"]}')

    c.execute(
        """
        UPDATE raw_materials_warehouse
        SET amount_stored = coalesce(amount_stored + ?, ?), last_delivery = ?
        WHERE ingredient_name = ?
        """,
        [rqb['quantity'], rqb['quantity'], rqb['deliveryTime'], ingredient_name]
    )

    c.execute(
        """
        SELECT amount_stored
        FROM raw_materials_warehouse
        WHERE ingredient_name = ?;
        """,
        [ingredient_name]
    )
    new_amount = [{"new_quantity": c.fetchone()}]
    logger.warning(f"c: {new_amount} {ingredient_name}")
    response.status = 201
    if len(new_amount) > 0:
        logger.warning("I am here")
        db.commit()
        return {"data": {
            "ingredient": ingredient_name,
            "quantity": new_amount[0]["new_quantity"]
        }}

    return {"data": ""}


@get('/ingredients')
def get_ingredients():
    c = db.cursor()

    c.execute(
        """
        SELECT ingredient_name, amount_stored, unit
        FROM raw_materials_warehouse
        JOIN ingredients
        USING (ingredient_name)
        """
    )
    if c:
        found = [{"ingredient": ing, "quantity": q, "unit": u} for ing, q, u in c]
        response.status = 200
        return {'data': found}

    response.status = 404
    return {'data': ""}


@post('/cookies')
def post_cookie():
    c = db.cursor()
    rqb = request.json
    name = unquote(rqb['name'])
    c.execute(
        """
        INSERT
        INTO recipes(cookie_name)
        values(?)
        """,
        [name]
    )

    recipe = rqb['recipe']
    for ingredient_amount in recipe:
        logger.warning(f'recipe: {name} ingredient: {ingredient_amount["ingredient"]}')
        c.execute(
            """
            INSERT
            INTO ingredient_list(cookie_name, ingredient_name, amount)
            VALUES (?,?,?)
            """,
            [name, ingredient_amount['ingredient'], ingredient_amount['amount']]
        )
    db.commit()
    response.status = 201
    return {"location": "/cookies/" + quote(name)}


@get('/cookies')
def get_cookies():
    c = db.cursor()
    c.execute(
        """
        SELECT cookie_name
        FROM recipes
        """
    )
    found = [{'name': n} for n, in c]
    response.status = 200
    return {'data': found}


@get('/cookies/<cookie_name>/recipe')
def get_recipe(cookie_name):
    cookie_name = unquote(cookie_name)
    c = db.cursor()
    c.execute(
        """
        SELECT ingredient_name, amount, unit
        FROM ingredient_list
        JOIN recipes
        USING (cookie_name)
        JOIN ingredients
        USING (ingredient_name)
        WHERE cookie_name = ?
        """,
        [cookie_name]
    )

    if c:
        found = [{'ingredient': i, 'amount': a, 'unit': u} for i, a, u in c]
        response.status = 200
        return {'data': found}

    response.status = 404
    return {'data': []}


@post('/pallets')
def post_pallets():
    rqb = request.json
    c = db.cursor()

    try:
        c.execute(
            """
            INSERT
            INTO pallets(cookie_name, production_date, status)
            VALUES(?, ?, 0)
            """,
            [rqb['cookie'], date.today()]
        )
        c.execute(
            """
            SELECT pallet_id
            FROM pallets
            WHERE rowid = last_insert_rowid()
            """
        )

        pallet_id, = c.fetchone()
        return_string = '/pallets/' + quote(pallet_id)
        response.status = 201
        db.commit()

    except:
        logger.warning("Exception!")
        return_string = ""
        response.status = 422

    return {'location': return_string}


@get('/pallets')
def get_pallets():
    query = """
    SELECT pallet_id, cookie_name, production_date, status
    FROM pallets
    WHERE 1=1
    """
    params = []
    if request.query.cookie:
        query += "AND cookie_name = ?"
        params.append(unquote(request.query.cookie))
        logger.warning(request.query.cookie)

    if request.query.before:
        query += "AND production_date < ?"
        params.append(unquote(request.query.before))
        logger.warning(request.query.before)

    if request.query.after:
        query += "AND production_date > ?"
        params.append(unquote(request.query.after))
        logger.warning(request.query.after)

    c = db.cursor()
    c.execute(query, params)

    # c.execute(
    #     """
    #     SELECT *
    #     FROM pallets
    #     """
    # )
    # logger.warning(f"this is in me: {c.fetchall()}")

    found = [{'id': pallet_id, 'cookie': cookie_name, 'productionDate': production_date, 'blocked': status}
             for pallet_id, cookie_name, production_date, status in c]

    response.status = 200
    return {"data": found}


@post('/cookies/<cookie_name>/block')
def block_cookie(cookie_name):
    query = """ 
    UPDATE pallets
    SET status = 1
    WHERE cookie_name = ?
    """
    params = [cookie_name]

    if request.query.before:
        query += "AND production_date < ?"
        params.append(request.query.before)
        # logger.warning(request.query.before)

    if request.query.after:
        query += "AND production_date > ?"
        params.append(request.query.after)
        # logger.warning(request.query.after)

    c = db.cursor()
    c.execute(query, params)
    db.commit()
    response.status = 205
    return ""


@post('/cookies/<cookie_name>/unblock')
def block_cookie(cookie_name):
    query = """ 
    UPDATE pallets
    SET status = 0
    WHERE cookie_name = ?
    """
    params = [cookie_name]

    if request.query.before:
        query += "AND production_date < ?"
        params.append(request.query.before)
        # logger.warning(request.query.before)

    if request.query.after:
        query += "AND production_date > ?"
        params.append(request.query.after)
        # logger.warning(request.query.after)

    c = db.cursor()
    c.execute(query, params)
    db.commit()
    response.status = 205
    return ""


run(host='localhost', port=PORT)
