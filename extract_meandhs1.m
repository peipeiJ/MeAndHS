pu = load ('D:\steganography\HM-16.20(extract)\workspace\PU.txt');
depth = load('D:\steganography\HM-16.20(extract)\workspace\depth.txt');
coeff = load('D:\steganography\HM-16.20£¨QDST£©\workspace\restore_coeff0.txt');
no_error_M = [1 0 -1 1 0 0 0 0 -1 0 1 -1 1 0 -1 1]; % Intra-frame no-error matrix
no_error_M=no_error_M';
H = [1 0 1 0 1 0 1;0 1 1 0 0 1 1;0 0 0 1 1 1 1];% Hamming code matrix
%H = [1 0 1;0 1 1]
c0=7,m0=3;
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
        %(0,0):(1,1)(-1,-1)
        if zerosum~=16 && abs(coeff1)==0 && coeff16==0
            s(z)=mod(abs(coeff1),2);
            index(z)=i;
            z=z+1;
        end
        if zerosum~=16 && coeff1==1 && coeff16==1
            s(z)=mod(abs(coeff1),2);
            index(z)=i;
            z=z+1;
        end
        if zerosum~=16 && coeff1==-1 && coeff16==-1
            s(z)=mod(abs(coeff1),2);
            index(z)=i;
            z=z+1;
        end
        if zerosum~=16 && abs(coeff1-coeff16)==0 && coeff16>=2
            z1=z1+1;
            hstu_z(z1)=i;
        end
        if zerosum~=16 && abs(coeff1-coeff16)==0 && coeff16<=-2
            z2=z2+1;
            hstu_f(z2)=i;
        end
    end
end
[n,s_len] = size(s);
count=floor(s_len/c0);
sum=1;

% Compute message vector
while sum<=count
    s0 = s((sum-1)*c0+1:sum*c0);
    s0=double(s0.');
    msg_extract1((sum-1)*m0+1:sum*m0) = mod(H*s0,2);
    sum=sum+1;
end

% Restoration
% Positions of carrier elements to be restored: digit
sum=1;
while sum<=count
    digit(sum) = bin2decPosition(msg_extract1,(sum-1)*m0+1,sum*m0);
    sum=sum+1;
end
[n,digit_len] = size(digit);

% Compute absolute coordinates for the restoration matrix
z=1;
for i=1:digit_len
    if digit(i)~=0
        pos(z)=index((i-1)*c0+digit(i));
        z=z+1;
    end
end

% Modify coefficients
[n,m1_len] =size(msg_extract1);
w=m1_len+1;
coeff1=coeff;
[n,pos_len] = size(pos);

for i=1:pos_len
    tu_dex=pos(i);
    if coeff((tu_dex-1)*16+1)==-1 && coeff((tu_dex-1)*16+16)==-1
        coeff1((tu_dex-1)*16+1:tu_dex*16)=coeff((tu_dex-1)*16+1:tu_dex*16)+no_error_M;
        msg_extract1(w)=0;
    end
    if coeff((tu_dex-1)*16+1)==1 && coeff((tu_dex-1)*16+16)==1
        coeff1((tu_dex-1)*16+1:tu_dex*16)=coeff((tu_dex-1)*16+1:tu_dex*16)-no_error_M;
        msg_extract1(w)=1;
    end
    w=w+1;
end

% Restore shifted TU
for i=1:z1
    tu_dex=hstu_z(i);
    coeff1((tu_dex-1)*16+1:tu_dex*16)=coeff((tu_dex-1)*16+1:tu_dex*16)-no_error_M;
end
for i=1:z2
    tu_dex=hstu_f(i);
    coeff1((tu_dex-1)*16+1:tu_dex*16)=coeff((tu_dex-1)*16+1:tu_dex*16)+no_error_M;
end

fid = fopen('D:\steganography\HM-16.20£¨QDST£©\workspace\restore_coeff.txt','wt');
fprintf(fid,'%g\n',coeff1);      
fclose(fid)
