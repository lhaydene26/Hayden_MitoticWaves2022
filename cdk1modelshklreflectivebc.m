function cdk1modelreflectivebc()

global af
global f0
global noiseamplitude
global forceamplitude


N_pts=512;

hx=1;
dt=1/20;

%dt=0.01/2;
tfinal=3000;

c(1:3) = [-5/2 4/3 -1/12];

for ii=1:N_pts+4
    f0(ii)=0.65-0.3*exp(-(ii-N_pts)^2/75^2)-0.15*exp(-(ii-0)^2/75^2);
end

%initial conditions
for indicesim=1:1
    indicesim
    D=5;
    a(1:N_pts+4)=0;%0.1086;
    incr(1:N_pts+4)=0;
    
    ind=0;
    for time=0:dt:tfinal
         for i=3:N_pts+2
            incr(i) = potential(a(i),time,i);
            incr(i) = incr(i)+ 1*ampnoise(a(i),time,i)*randn()/sqrt(dt);
        end
        a(1)=a(5);
        a(2)=a(4);
        incr(3) = incr(1)+ D*(c(3)*a(1)+c(2)*a(2)+c(1)*a(3)+c(2)*a(4)+c(3)*a(5))/(hx*hx);
        incr(4) = incr(2)+ D*(c(3)*a(2)+c(2)*a(3)+c(1)*a(4)+c(2)*a(5)+c(3)*a(6))/(hx*hx);
        
        for i=5:N_pts
            incr(i) = incr(i)+ D*(c(3)*a(i-2)+c(2)*a(i-1)+c(1)*a(i)+c(2)*a(i+1)+c(3)*a(i+2))/(hx*hx);
        end
        a(N_pts+3)=a(N_pts+1);
        a(N_pts+4)=a(N_pts);
        incr(N_pts+1)=incr(N_pts+1)+D*(c(3)*a(N_pts-1)+c(2)*a(N_pts)+c(1)*a(N_pts+1)+c(2)*a(N_pts+2)+c(3)*a(N_pts+3))/(hx*hx);
        incr(N_pts+2)=incr(N_pts+2)+D*(c(3)*a(N_pts)+c(2)*a(N_pts+1)+c(1)*a(N_pts+2)+c(2)*a(N_pts+3)+c(3)*a(N_pts+4))/(hx*hx);
        
        %    incrdeg(a>0.7)=1/120;
        %    deg=deg+incrdeg;
        %    deg=min(deg,1/120);
        %    incr(deg>0)=incr-deg;
        a=a+incr*dt;
        a(a<0)=0;
        
        if(mod(time,1)==0)
            ind=ind+1;
            af(:,ind,indicesim)=a;
            for i=1:N_pts
                noiseamplitude(i,ind)=ampnoise(a(i),time,i);
                forceamplitude(i,ind)=potential(a(i),time,i);
            end
        end
        
    end
    %indicesimn=num2str(indicesim);
    %filename=['datafromnewmodel/differentdiffusion/new/embryo',indicesimn,'.mat'];
    %save(filename,'af');
end
end

function y=potential(x,t,ii)
global f0
KK=0.33;
nu=5;
c0=12;
c1=65;
b0=24;
b1=100;
k0=8;

timescale=0.0001/0.7;

y=timescale*(k0+(c0+c1*x^nu/(x^nu+KK^nu))*(min(k0*timescale*t,2)-x)*(1-f0(ii)*(0.4^10/(0.4^10+x^10)))-f0(ii)*x*(b0+(b1*KK^nu/(KK^nu+x^nu)*(0.4^10/(0.4^10+x^10)))));
end

function y=ampnoise(x,t,ii)
global f0
KK=0.33;
nu=5;
c0=12;
c1=65;
b0=24;
b1=100;
k0=8;

aa=0.2/512;
timescale=0.0001/0.7;

y=sqrt(timescale*(k0+(c0+c1*x^nu/(x^nu+KK^nu))*(min(k0*timescale*t,2)-x)*(1-f0(ii)*(0.4^10/(0.4^10+x^10)))+f0(ii)*x*(b0+b1*KK^nu/(KK^nu+x^nu))*(0.4^10/(0.4^10+x^10))));
end