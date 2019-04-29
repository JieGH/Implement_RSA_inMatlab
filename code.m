
% This code only able to process greyscal images
% This code requires:
% 1: vpi package Variable Precision Integer Arithmetic by John D'Errico
% https://uk.mathworks.com/matlabcentral/fileexchange/22725-variable-precision-integer-arithmetic
% 2: Image processing toolbox


clc
clear
packages = 9866;
while(packages == 9866)
    packages=input('Have you read the comments in the beginning of code ? \nInput a number to continue \n');
end

fprintf ('Start of create the public key \n')
fprintf ('Example prime number? 17 19 23 29 43 53 79 89 103 127 137 179 199 \n')
fprintf ('--p q should be different \n')
fprintf ('--If p q larger than these example, the program will be very slow\n')
fprintf ('--Unless you have a powerful Computer (iPad is not included) \n')

% give me a large positive prime numbers P
p=input('Give me a large positive prime numbers p: ');
fprintf('The p you gave is : %d\n',p)
while (isprime(p) ~= 1)
    fprintf ('p is not a prime, try again\n')
    p=input('Give me a large positive prime numbers p: ');
end
% give me a large positive prime numbers Q
q=input('Give me a large positive prime numbers q: ');
fprintf('The q you gave is : %d\n',q)
while (isprime(q) ~= 1)
    fprintf ('q is not a prime, try again\n')
    q=input('Give me a large positive prime numbers q: ');
end
%compute X
x = (p-1)*(q-1);
fprintf('The x calculated is : %d\n',x)

e=input('Give me a e: ');
% make sure the e you choose is coprime
while (gcd(e,x) ~= 1)
    fprintf ('The e you gave is NOT correct one, try again\n')
    e=input('Give me a e (prefer smaler than 10 ): ')
end
fprintf('The e is : %d\n',e)

%compute n
n = p*q;
fprintf('The n calculated is : %d\n',n)
fprintf ('--Public key is: %d %d\n', n,e)
kp = [n e];
fprintf ('END of create the public key\n')
%To create the secret key Ks:

fprintf ('Start of create the secret key \n')

%Compute d, such that    d * e mod x = 1
% use euclidean algorithm to find out the d 
step=0; % to log the step of calculation
i=1; 
pp=[];qq=[]; 
if(abs(x)>abs(e))
    p=abs(x);q=abs(e);
else
    q=abs(x);p=abs(e);
    pp(i)=p;qq(i)=q;
end
r=mod(p,q);
while r~=0
    i=i+1;
    step=step+1;
    p=q;q=r;r=mod(p,q);
    pp(i)=p;qq(i)=q;
end 
j=1;d=0;k=step+1;
while k~=0
    temp=j;
    j=d;
    d=temp-fix(pp(k)/qq(k))*d; 
    k=k-1;
end
while(j>0) 
    j=j-e;
end
d=-(j*x-q)/e; 

%fprintf('%d %d\n',x,d)
fprintf('The d calculated is : %d\n',d)
%END of compute D
fprintf ('--Private key is: %d %d\n', n,d)
ks = [n,d];
fprintf ('END of create the secret key \n')
fprintf ('Start of encryption\n')

fprintf ('Pic 1: Smile face (small). Pic 2: X-Ray pic (big) Pic 3: Camera man (large)\n')
pic = input('Which pic you want to use? [1 2 3] ');
if (pic == 1)
    filename = 'haha_tiny_bw.png';
    p_t_e = imread(filename)
    
elseif (pic ==2)
    filename = 'xray_big.png';
    p_t_e = imread(filename)
    
elseif (pic ==3)
    filename = 'camera_man_large.png';
    p_t_e = imread(filename)
else
    p_t_e = [0 25 50 75 100 125 150 175 200 225 254 ]    
end

sz = size(p_t_e); % Measure the weight and height of the input image;
% add random number to image for better encryption results
ran_matr = randi(40, sz(1), sz(2)); 
p_t_e_rand = uint8(p_t_e) + uint8(ran_matr);

fprintf ('The ciphertext is: ')
p_t_e_vpi = vpi(p_t_e_rand); % Convert grey level value to vpi type
c_t = mod(p_t_e_vpi.^e,n) % Calculate ciphertext with public key

c_t_1000 = c_t.*1000;
% array convertion
for Weight = 1 : sz(1)
    for Height = 1 : sz(2)
        array(Weight,Height) =  single(c_t_1000(Weight,Height));
    end
end
array_dev_1000_c = array./1000;


fprintf ('\nEND of encryption\n')
fprintf ('Start of decryption\n')

c_t_vpi = vpi(c_t); % Convert to vpi type
fprintf ('The decrypted plain text is: ')

P_t_d = mod(c_t_vpi.^d,n);  % Decrypt the ciphertext to plaintext with private key
fprintf ('\nEND of decryption\n')

P_t_d_1000 = P_t_d.*1000;
% array convertion
for Weight = 1 : sz(1)
    for Height = 1 : sz(2)
        array(Weight,Height) =  single(P_t_d_1000(Weight,Height));
    end
end
array_dev_1000_d = array./1000-ran_matr


subplot(1,3,1), imshow(uint8(p_t_e)) % Original image
title('Original image');
subplot(1,3,2), imshow(uint8(array_dev_1000_c)) % Encrypted image
title('Encrypted image');
subplot(1,3,3), imshow(uint8(array_dev_1000_d)) % Decrypted image
title('Decrypted image');
