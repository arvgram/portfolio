[y, Fs] = audioread('fa.wav');

%%
plot(y)
%%
x1 = 1976;
x2 = 4080;

suby = y(2826:3026);
plot(suby)

%%

acf(suby, 50, 0.05, true)

%%
Padd = 1024;
N = length(suby);
X = fftshift( abs( fft(suby, Padd) ).^2 / N );

ff = (0:Padd-1)'/Padd-0.5;
plot(ff*8000,X);        


%%
semilogy(ff*8000,X)



