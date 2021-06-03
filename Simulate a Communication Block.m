%Mohamed Assaker 46-1370  T7
%Reem Osama      46-0688  T7
%Waad Mohamed    46-5078  T7
%Mohamed Samir   46-17946 T4

clc
clear all
close all

t = 0:0.1:15;
x = sin(0.2*pi*t);

%sampling
plot(t,x); hold on
xs = x(1:2:end);

%Quantizer
L = 16;
a = max(x);
delta1 = 2*a/L;
Xs = -a:delta1:a;
Xq = -a+delta1/2:delta1:a-delta1/2;
quantized = zeros(1,length(xs));
quantized_levels = zeros(1,length(quantized));

for i = 1 : length(xs)
     for j = 1 : length(Xs)
         if(xs(i)>Xs(j) && xs(i)<Xs(j+1))
             quantized(i) = Xq(j);
             quantized_levels(i) = find(Xq==quantized(i));
         end
     end
end   

%Error
Error = quantized-xs;

%Mean of each error for each level
Mean_Error = mean(abs(Error));

%Variance 
Variance_Error = var(Error);

%SQNR
SQNR = power(a,2)/Variance_Error

%Huffman Encoder
lvl = 0:1:L;
P=lvl;
for i = 1:length(lvl)
    n = find(quantized_levels==lvl(i));
    P(i)=length(n)/length(quantized_levels);
end

symbols = (0:L);
[dict,avglen] = huffmandict(symbols,P)
for i = 1:L+1
    samplecode = dict{i,2}
end

comp = huffmanenco(quantized_levels,dict);

%Huffman Decoder
dsig = huffmandeco(comp,dict);
dequantized = zeros(1,length(dsig));
for i=1:length(dsig) 
    m = quantized(find(quantized_levels(i)==dsig));
    dequantized(i) = m(1);
end

plot(t(1:2:end),dequantized)
legend('Input','Output');
title('Input vs Output');

%Calculate the efficiency of your compression code & the compression rate.
msg = dequantized;

%Entropy
norep = unique(msg);
prob = zeros(1,L+1);

for i = 1:length(norep)
    count = 0;
    for j = 1:length(msg)
        if norep(i) == msg(j)
            count = count+1;
        end
    end
    prob(i) = count/length(msg);

end

Entropy = sum(-prob.*log2(prob))
selfinfo = -log2(prob)

%average code length
average_code_length = avglen

%code efficiency
efficiency = Entropy / average_code_length

%compression rate
compression_rate=log2(16)/average_code_length

%To improve the output to reach the input as close as possible we can
% increase sampling rate
% increase number of levels