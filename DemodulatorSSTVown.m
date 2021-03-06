
% Desmodulacao de um sinal SSTV na componente que codifica a intensidade
% das linhas na frequencia

 clear; clc

[x,Fa]= audioread('m.wav');
x = x(:,1);
Ta= 1/Fa;
% Determina o numero de amostras para analise em frequ?ncia
Na= round(0.03*Fa);

% Projeto dos filtros do codigo VIS
B= 100;
f= [1100 1200 1300 1500 1900];
h= zeros(Na+1,4);
for k= 1:5,
    F= [0 f(k)-B  f(k)-B/2 f(k)+B/2  f(k)+B Fa/2]/(Fa/2);
    M= [0 0 1 1 0 0];
    W= [10 1 10];
    h(:,k)= firpm(Na,F,M,W);
    H(:,k)= freqz(h(:,k),1,1024,Fa);
end
% Mostra os 3 filtros
figure(1)
fk= (0:1023)*Fa/2048;
plot(fk,20*log10(abs(H)))
title('Resposta em frequencia dos filtros')

y= fftfilt(h,x);

% Detetor de envolvente
hl= fir1(Na,0.01);
e= filter(hl,1,y.*y);
figure(2) 
t= (0:length(e)-1)*Ta*1000;
plot(t,e(:,[2 4]))
xlabel('ms')
title('Saida dos detetores de envolvente')
legend('1200Hz','1500Hz')

%saturação do nível de saida dos detetores de envolvente

e((e(:,2)>=0.025),2)= 0.025;
e((e(:,4)>=0.025),4)= 0.025;
plot(t,e(:,[2 4]))
xlabel('ms')
title('Saida dos detetores de envolvente')
legend('1200Hz','1500Hz')
% Cada linha tem cerca de 1614 amosrtras do sinal e um pixel dura cerca de
% 6 amostras. Como se usou uma DFT de 128 amostras vamos ter 65 n?veis de
% cinza.

%encontra os pulsos de sincronização  de linha

[pks,locs] = findpeaks(e(:,2),'MinPeakHeight',0.012);

nfft = 512;
fvals = (Fa*(0:(nfft/2)-1)/nfft);
tpixel = (146.432e-3)

tsync = 4862e-6
tsyncsample = round(tsync/Ta)
ini = locs(7);
pix = 1 : 1 : 3*256;
lines = locs(7:end);
locs= locs(7:end);
figure(4)
cfreqs = zeros(320,256,3);

k = 0;

for j = 1 : length(lines)-1 
    pixelsample = round((locs(j+1)-locs(j))/(320*3));
    porchsamples = round((locs(j+1)-locs(j))/320);

    
   for i = 1 : 320*3

         fftx = fft(x(locs(j)+(i-1)*pixelsample:(locs(j))+(i*pixelsample)),nfft) ;
         maxs = find(abs(fftx(((nfft/2)+1):end)) == max(abs(fftx((nfft/2)+1:end))));
         if (i <= 320)
              aux = fvals(max(maxs))/9;
           if aux > 2300 
               aux =2300
           end;
           if aux < 1500
               aux = 1500
           end;
              
         cfreqs(i,j,2) = aux;
         end
         if( i > 320 && i <= 320*2)
           aux = fvals(max(maxs))/9;
           if aux > 2300 
               aux =2300
           end;
           if aux < 1500
               aux = 1500
           end;
              
         cfreqs(i-(320*1)+1,j,1) = aux;
         end
         if (i > 2*320 && i <= 320*3)
           aux = fvals(max(maxs))/9;
           if aux > 2300 
               aux =2300
           end;
           if aux < 1500
               aux = 1500
           end;
              
         cfreqs(i-(320*2)+1,j,3) = aux;
         end;    
                 
      

    end;
end;

fig = zeros(320,256,3);
%converte as frequências em bytes de cor 0-256
for k = 1 : 3
    for i = 1 : 256
        for j = 1: 320
            fig(j,i,k )= round((cfreqs(j,i,k)-1500)/3.1);
        end;
    end;
end;

imshow(uint8(fig),[])

