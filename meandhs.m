pu = load ('D:\steganography\HM-16.20£¨QDST£©\workspace\PU.txt');
depth = load('D:\steganography\HM-16.20£¨QDST£©\workspace\depth.txt');
coeff = load('D:\steganography\HM-16.20£¨QDST£©\workspace\coeff.txt');
msg = load('D:\steganography\HM-16.20£¨QDST£©\workspace\msg.txt');
no_error_M = [1 0 -1 1 0 0 0 0 -1 0 1 -1 1 0 -1 1]; % Intra-frame no-error matrix
no_error_M=no_error_M';
H = [1 0 1 0 1 0 1;0 1 1 0 0 1 1;0 0 0 1 1 1 1];% Hamming code matrix
%c0=7,m0=3;
[len,n] = size(depth);
z=1;z1=0;z2=0;
% Extract carrier vector s
for i=1:len
    if pu(i)==3 && depth(i)==3
        zerosum=0;
        for j=1:16
            if coeff((i-1)*16+j)==0 
                zerosum=zerosum+1;
            end
        end
        coeff1=coeff((i-1)*16+1);
        coeff16=coeff((i-1)*16+16);
        if zerosum~=16 && abs(coeff1)==1 && coeff16==0
            s(z)=mod(abs(coeff1),2);
            index(z)=i;
            z=z+1;
        end
        if zerosum~=16 && abs(coeff1-coeff16)==1 && coeff16>=1
            z1=z1+1;
            hstu_z(z1)=i;
        end
        if zerosum~=16 && abs(coeff1-coeff16)==1 && coeff16<=-1
            z2=z2+1;
            hstu_f(z2)=i;
        end
    end
end
[n,s_len] = size(s);
count=floor(s_len/c0);
sum=1;
% Compute dependency vector d
while sum<=count
    s0 = s((sum-1)*c0+1:sum*c0);
    s0=s0';
    d((sum-1)*m0+1:sum*m0) = H*s0;
    sum=sum+1;
end
[n,d_len] = size(d);
d=mod(d,2);
msg=zeros(1,d_len);
b=msg(1:d_len);

% The positions of carrier vector that need modification: digit
sum=1;embit=0;
digit1 = xor(b,d);
while sum<=count
    if embit<=1000000
        digit(sum) = bin2decPosition(digit1,(sum-1)*m0+1,sum*m0);
    else
        digit(sum) = 0;  
    end
    sum=sum+1;
    embit=embit+4;
end
[n,digit_len] = size(digit);

% Calculate absolute coordinates of the modification matrix
z=1;
for i=1:digit_len
    if digit(i)~=0
        pos(z)=index((i-1)*c0+digit(i));
        z=z+1;
    end
end

% Shift TU
coeff1=coeff;
for i=1:z1
    tu_dex=hstu_z(i);
    coeff1((tu_dex-1)*16+1:tu_dex*16)=coeff((tu_dex-1)*16+1:tu_dex*16)+no_error_M;
end
for i=1:z2
    tu_dex=hstu_f(i);
    coeff1((tu_dex-1)*16+1:tu_dex*16)=coeff((tu_dex-1)*16+1:tu_dex*16)-no_error_M;
end

% Modify coefficients
w=d_len+1;
[n,pos_len] = size(pos);
for i=1:pos_len
    tu_dex=pos(i);
    if coeff((tu_dex-1)*16+1)==-1 && msg(w)==1
        coeff1((tu_dex-1)*16+1:tu_dex*16)=coeff((tu_dex-1)*16+1:tu_dex*16)+no_error_M;
    end
    if coeff((tu_dex-1)*16+1)==-1 && msg(w)==0
        coeff1((tu_dex-1)*16+1:tu_dex*16)=coeff((tu_dex-1)*16+1:tu_dex*16)-no_error_M;
    end
    if coeff((tu_dex-1)*16+1)==1 && msg(w)==1
        coeff1((tu_dex-1)*16+1:tu_dex*16)=coeff((tu_dex-1)*16+1:tu_dex*16)+no_error_M;
    end
    if coeff((tu_dex-1)*16+1)==1 && msg(w)==0
        coeff1((tu_dex-1)*16+1:tu_dex*16)=coeff((tu_dex-1)*16+1:tu_dex*16)-no_error_M;
    end
    w=w+1;
end

fid = fopen('D:\steganography\HM-16.20£¨QDST£©\workspace\watermark0.txt','wt');
fprintf(fid,'%g\n',coeff1);      
fclose(fid);
