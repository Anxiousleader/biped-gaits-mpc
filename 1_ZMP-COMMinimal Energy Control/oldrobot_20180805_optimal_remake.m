function [yx,y,bodyp2,totZMP,ZMP_body,zmpdesign,Rp,Lp] = calcu20180805_remake
palse=1;
stnum =0;
num =20;
stepwidth=250;
stepx=100;
global Link N1;
%global comx;global bodyp;

%���ȡΪ���룬if elseʹ�õ͵�ƽ����ʱ��������⣬�Ӷ����Ч��
dt=0.02;
[t_goal,comx,comy,comz,Rp,RR,Rv,Rw,Lp,LR,Lv,Lw]=plan_com(dt,num,stepwidth,stepx);
bodyp1=[comx;comy;comz];
t=t_goal;
N1=length(t);
if palse==1
    Initial(N1);
    for pii=1:2 %���forѭ�������������ZMP��ѭ������Ϊ��������
        %-----��������������ҽŵ�λ�á�--------
    bodyp2=bodyp1';
    bodyp=reshape(bodyp1,[3,1,N1]);
    [bp,bR,bv,bw]=trans_bp(bodyp,t,N1);%trans�����bodyp��Ȼ����ά����
    Link(1).p=bp;Link(1).R=bR;Link(1).v=bv;Link(1).w=bw;
    R_RefpR.v=Rv;R_RefpR.w=Rw;R_RefpR.p=Rp;R_RefpR.R=RR;
    L_RefpR.v=Lv;L_RefpR.w=Lw;L_RefpR.p=Lp;L_RefpR.R=LR;
    Forward_Kinematics(2,N1);
    InverseKinematics(6,R_RefpR);
    InverseKinematics(11,L_RefpR);
    com=calCom();%������������
    [totZMP,ZMP_body]=cal_linkZMP(com,R_RefpR,L_RefpR,t);
    [del_com,~,zmpdesign]=cal_del_x(totZMP,t,comx,comy);

    bodyp=bodyp+reshape(del_com,3,1,[]);%delc-comԭΪ��ά����ת��Ϊ��ά����
    end 
    c=zeros(N1,10);
    for j=2:11
        c(:,j-1)=Link(j).q(:);%Nx10
    end
    y=c;
else 
    y=zeros(N1,10);
end
y=y(:);
clear global bodyp;
y=reshape(y,[],10);
yx=[t',y];

figure (11)
hold on;
plot(zmpdesign(1,:),zmpdesign(2,:),'--');
plot(totZMP(1,:),totZMP(2,:),'r');
legend('zmpdesign','totZMP');
figure (12)
plot(t,y);
end

function Initial(tN)
global Link
Link(1).name='Body';
Link(1).brotherID=0;
Link(1).childID=2;
Link(1).motherID=0;
Name={'Body','Rleg_hip_r','Rleg_hip_p','Rleg_knee','Rleg_ank_p','Rleg_ank_r',...
      'Lleg_hip_r','Lleg_hip_p','Lleg_knee','Lleg_ank_p','Lleg_ank_r'};
BrotherID=[0 7 0 0 0 0 0 0 0 0 0];
ChildID=[2 3 4 5 6 0 8 9 10 11 0];
MotherID=[0 1 2 3 4 5 1 7 8 9 10];
a_Init={[1 0 0],[0 1 0],[0 1 0],[0 1 0],[1 0 0],...
   [1 0 0],[0 1 0],[0 1 0],[0 1 0],[1 0 0]};
b_Init={[-4 -128 -64],[0 0 -78],[0 0 -230],[0 -2 -230],[0 0 -78],...
    [-4 128 -64],[0 0 -78],[0 0 -230],[0 -2 -230],[0 0 -78]};
c_Init={[0,0,-0.79],[1.62,0.01,-6.13],[0,-0.85,-58.72],...
        [0,-0.4,-114.99],[1.62,0.01,-71.87],[9.9,0,-67.4],...
      [1.62,-0.01,-6.13],[0,0.85,-58.72],[0,0.4,-114.99],...
      [1.62,-0.01,-71.87],[9.9,0,-67.4]};
m_Init=[8.00,1.600,1.783,2.591,1.600,1.121,1.600,1.783,2.591,1.600,1.121];
dq_Init=zeros(1,11);%link(1)��dqû�����塣

I1=[147497.715,0.00,0;0.00,16281.200,0.00;0.00,0.00,163528.242];
I2=[3230.591,-0.121,70.560;-0.121,1547.051,46.679;70.560,46.679,3029.561];
I3=[13916.918,0.00,0.00;0.00,12449.332,971.630;0.00,971.630,2283.117];
I4=[41751.921,0.00,0.00;0.00,41282.239,117.776;0.00,117.776,1316.250];
I5=[11439.657,-0.121,-272.800;-0.121,9756.118,-48.452;-272.800,-48.452,3029.561];
I6=[5749.713,0.00,-811.110;0.00,7164.997,0.00;-811.110,0.00,1876.293];
I7=[3230.591,0.121,70.560;0.121,1547.051,-46.679;70.560,-46.679,3029.561];
I8=[13916.918,0.00,0.00;0.00,12449.332,-971.630;0.00,-971.630,2283.117];
I9=[41751.921,0.00,0.00;0.00,41282.239,-117.776;0.00,-117.776,1316.250];
I10=[11439.657,0.121,-272.800;0.121,9756.118,48.452;-272.800,48.452,3029.561];
I11=[5749.713,0.00,-811.110;0.00,7164.997,0.00;-811.110,0.00,1876.293];
I_Init={I1,I2,I3,I4,I5,I6,I7,I8,I9,I10,I11};
v_Init=zeros(11,1);
w_Init=zeros(11,1);
q=[0 0 0 0.2 0 0 0 0 0.2 0 0];%��һ����û���õ�
%����q��I���ڵ���ά���ơ�
for j=1:1:11
    Link(j).name=Name(j);
    Link(j).brotherID=BrotherID(j);
    Link(j).childID=ChildID(j);
    Link(j).motherID=MotherID(j);
    Link(j).c=repmat(c_Init{1,j},[1,1,tN]);
    Link(j).m=m_Init(j);
    Link(j).dq=dq_Init(j);
    Link(j).I=repmat(I_Init{1,j},[1,1,tN]);%�Ѿ���ŵ�cell���棬Ҫע��cell��Ԫ��ȡ��
    Link(j).v=v_Init(j);
    Link(j).w=w_Init(j);
    Link(j).q=repmat(q(j),[1,1],tN);
    if j>1
    Link(j).a=a_Init{1,j-1}';
    Link(j).b=b_Init{1,j-1}';
    end
end
end


function [t_goal,comx,comy,comz,Rp,RR,Rv,Rw,Lp,LR,Lv,Lw]=plan_com(dt,num,stepwidth,stepx)   %%���Ĺ켣�滮
%===========�ؼ�������ʼ��======
Tsup=0.8;
Tdou=1-Tsup;
T=Tsup+Tdou;
g=9800;
Zc=736;
Tc=sqrt(Zc/g);
%����capture-point���㲿λ�õ�����λ��
t_adjust=Tdou/2;              %һ�����������ڵ���������ʱ�䣬�ֶδ���        ---------------���Կ���ȥ��
t_des=3.7;                    %���㵱ǰʱ�̵Ĳ������ڡ�
theta=0;                      %����capture-pointʱ��ǰ�㲿ƫת��
%---��ֹ״̬���ȶ�״̬�Ĺ���
T_ini=4;                      %��һ�����ҽ�����ʱ��
t0=dt:dt:T_ini;               %��һ��ʱ���������
b1=100;                       %��ǰ�����㳤��
COMy0=130;%133.5              %��������Ȼվ�˰���
shor=20;
%==�Ƚ�����˼����������Ҫ����ȷ���ȶ�״̬�µ����ڵ����ĺ͹켣=======
[comx,comy,footx1,footy1,t1,SSP,DSP]=position_capture_region_Inout(stepwidth,stepx,t_adjust,t_des,theta,Tc,Tsup,num,dt);
%ע����������˫���࣬���е����࣡��������������������������������������������������������������������������������������
%����������������������������������������������������������������������������������������������������������������������
%����һ�Σ�ѡȡcomy��һ����Сֵ��Ӧ���±꣬��ҪK�п��ܳ������ŵ��������������ֻ�õ�K2����ʱ����Ҫ�ܣ��Ժ�Ľ�����
%�ҽ�������һ��������ڶ�����˫������ʼ�׶�
%Ҳ����1s,���ݹ滮����1s�����꣨71.65,48.81��
N1=fix(T/dt);
tn=length(t1);
                                         
 Dest1=[dt 3*dt T_ini/8 T_ini/4 T_ini/2 3*T_ini/4 T_ini-T/2 T_ini-Tdou T_ini-dt T_ini];       %��ʼ�׶���ֻ����ҽ���ǰ��һ������������Ҳ�ƶ����ҽ���
 x1=[0 -0.1 -20 -5 b1/8 b1/4 b1/2 b1-shor comx(N1-1,:) comx(N1,:)];
 y1=[1 2 1*stepwidth/4 stepwidth/2 COMy0 COMy0  (COMy0+stepwidth/2)/2 3*stepwidth/8 comy(N1-1,:) comy(N1,:)]; 

pp=pchip(Dest1,x1);
comx0=ppval(pp,t0);
comy0=ppval(pp2,t0);
comx1=comx((N1+1):tn,:);
comy1=comy((N1+1):tn,:);
pp2=pchip(Dest1,y1);
comx=[comx0,comx1'];
comy=[comy0,comy1'];

Destx=[0 0.01 0.02 0.03 T_ini/2-2*dt T_ini/2-dt T_ini/2 3*T_ini/4 T_ini];
z1=[780 779.95 779.85 779.7 736.41 736.1 736 736 736];
pp3=pchip(Destx,z1);
comz0=ppval(pp3,t0);
comz1=736*ones(1,tn-N1);
comz=[comz0,comz1];
N_goal=length(comx);
t_goal=dt:dt:(dt*N_goal);
%=========�㲿�켣=============
%ֱ��������ǰ�ĺ������޸ĵ�һ���Ĳ���
[Lp,LR,Lv,Lw,Rp,RR,Rv,Rw]=FootpR(t_goal,footx1,footy1,T_ini,dt,SSP,DSP);

end
%%%����ZMP��COM���㲿�켣


function [x,y,footx,footy,t,SSP,DSP]=position_capture_region_Inout(stepwidth,stepx,t_adjust,t_des,theta,Tc,Tsup,num,dt)
%%%%%
[x,y,Vx,Vy,footx,footy,px,py,t,SSP,DSP]=position_ZMP_COM_threemassmodel_footplace(stepwidth,stepx,t_adjust,Tc,Tsup,num,dt);

end
%����ZMP-����λ�ƺ��ٶ�--


function  [x,y,Vx,Vy,footx,footy,px,py,t,SSP,DSP]=position_ZMP_COM_threemassmodel_footplace(stepwidth,stepx,t_adjust,Tc,Tsup,num,dt)   
%%================���ʵ��������λ��========================
%�㲿λ�þ��������λ�ã�����Ҫ���١�t_adjust��ʾ��ʼ������ʱ�̡���̬���г�ʼ��

N=num;%------���ڱ�����У���Ϊ�ɵ����ڣ�����д��ͳһ��ʽ
SSP=Tsup*ones(N,1);
T=1;
TN=N*T;
t=0.02:dt:TN;  %%����num�����ڵĲ�������֮��
[~,XN]=size(t);
DSP=T*ones(N,1)-SSP;
T_int=0;      %ʱ�̵ĳ�ʼ��
LZMPy0=130;   %��ֹ״̬�����ҽŲ���
length=75;    %�㲿ǰ���㳤��
width=55;     %�㲿����
Sx=stepx*ones(N,1);  
Sy=stepwidth*ones(N,1);  %���в�������,
%---��һ�����ҽţ���������---
Sy(1,:)=LZMPy0+stepwidth/2;


%%%%%%%%%%%%%%%%������ʼ��%%%%%%%%%%%%%%%%%
%ÿ�����е�Ԫ���ĳ�ʼλ�ú���ֹλ�á��ٶȣ���ʼ����
%ע������λ�ú��ٶȶ�������ھֲ�����ϵ���ٶ��ھֲ�����ϵ��ȫ������ϵ������ͬ�ġ�
x_init=zeros(N,1);
y_init=zeros(N,1);
Vx_init=zeros(N,1);
Vy_init=zeros(N,1);

x_end=zeros(N,1);
y_end=zeros(N,1);
Vx_end=zeros(N,1);
Vy_end=zeros(N,1);
%------�滮����ŵ�λ�ã�Ҳ���Ǹ���ʱ�ھֲ�����ϵ�ĳ�ʼλ�ã������ȫ������ϵ��-----
footx=zeros(N,1);
footy=zeros(N,1);

%-------����ʱ�̵�����λ�ú��ٶȣ������ȫ������ϵ�� �ȶ������飬���������
x=zeros(round((N)*(T)/dt),1);
y=zeros(round((N)*(T)/dt),1);
Vx=zeros(round((N)*(T)/dt),1);
Vy=zeros(round((N)*(T)/dt),1);
%״̬������ʼ״̬
Rx=zeros(round((N)*(T)/dt),2);
Ry=zeros(round((N)*(T)/dt),2);
%˫�����ڼ���ζ���ʽϵ����ʼ��
 ax=zeros(N,6);
 ay=zeros(N,6);

%-----����ʱ�̵�ZMPλ�ã������ȫ������ϵ��====
px=zeros(round((N)*(T)/dt),1);
py=zeros(round((N)*(T)/dt),1);
%%%%%%%%%%%%%%������Ҫ�ľ��󣬲ο����ġ�
%%%%%%%%%%%%%matlab��˫���������Ѿ����˰���������
%����ZMPλ�ú�����λ�á�
%����Ҫ�ı�����ڵ���ʶ����Ϊ��һ���ھ��Ǵ�˫���࿪ʼ�ģ���Ϊ˫�����ǻ����˿�ʼ�����ڵ�һ��׼���׶Ρ�
 for n_int=1:1:N  %%�����Nָһ����N�����ڣ�
      %��һ������˫����,�Ƚ����⣬Ŀǰר��д����------
        if n_int==1    %��һ������Ϊ˫������ÿһ���Ŀ�ʼ������ʼʱ���Ѿ����˫���࣬������˫�����ʼʱ��
            Kn=round(T_int/dt);  
            %�ֲ�����ϵ------
            footx(n_int)=0;
            footy(n_int)=LZMPy0;  %��Ϊ��һ��
%----------------------------------------------
            K=round(DSP(n_int)/dt);       %˫����ʱ������
            
            %���嵥�����ʼ��ĩ����λ�ú��ٶ�
            %����������������ͬԭ�ο������е����ĳ�ĩ�ٶȻ����Ų����͵�����仯���仯�����������ֱ����ĳһ��˫����ĳ�ĩ�����ٶ���ȣ���ȷ����������Ӧ����
            %��������⽻��˫����������˫����ı߽�������Ҫ�ɱ�����Ŀ�굥������ٶȣ�λ��������%���Ǳ���������ԭ�ο����׵����� 
            %��Ҫ��Բ�ͬ������������
            %%������˼���ǣ�����Ӧ�������е��������ʱ�̵�λ�ú��ٶȣ�Ȼ���������������д����ʼʱ�̵�λ�á�
            x_end(n_int)=(Sx(n_int)-10*DSP(n_int)*length)/2;               %�������ڵĲ����йأ�������Ҫ����ĩ״̬λ�ò�����˫�������ʱ������λ��Ӧ�ÿ�����һ��֧���㣬zmpӦ����һ֧�����Ե
            y_end(n_int)=(-1)^(n_int)*(Sy(n_int)-10*DSP(n_int)*width)/2;   %�������ڵĲ����йأ�������Ҫ����ĩ״̬λ�ò�����            
            Vx_end(n_int)= Tc*coth(Tc*SSP(n_int)/2)*x_end(n_int);          %LIPM�μ������˻����ˡ�
            Vy_end(n_int)= Tc*tanh(Tc*SSP(n_int)/2)*y_end(n_int);
            %�������ʼʱ��-----------
            x_init(n_int)=-x_end(n_int);              %���Գ�
            y_init(n_int)=y_end(n_int);               %���Գ�
            Vx_init(n_int)= Vx_end(n_int);
            Vy_init(n_int)=-Vy_end(n_int);                    
            %=======������,��С�������ƣ��������==
            
            Kssp=round(SSP(n_int)/dt);       %������ʱ������
            D_T=calcu_D_T(Tc,SSP(n_int));
            E_AT=calcu_E_AT(Tc,SSP(n_int));
            %�μ���С�����������ģ�״̬ת�ƾ����Լ�����ķ����  ��ν״̬ת�ƾ�����LIPMĩ��λ�á��ٶȼ�����󣬡����˻����ˡ�
            for i=1:Kssp
            px(Kn+K+i,1)=[sinh(Tc*i*dt),cosh(Tc*i*dt)]*D_T*([x_end(n_int);Vx_end(n_int)]-E_AT*[x_init(n_int);Vx_init(n_int)])+footx(n_int);   %������ZMP��С�������ۼ���
              %ע��ת�Ƶ�ȫ������ϵ��
            py(Kn+K+i,1)=[sinh(Tc*i*dt),cosh(Tc*i*dt)]*D_T*([y_end(n_int);Vy_end(n_int)]-E_AT*[y_init(n_int);Vy_init(n_int)])+footy(n_int);   %ע��ת�Ƶ�ȫ������ϵ��
            end
                    
            %---��ζ���ʽ��ֵ�ı߽�����,����Ҫ�õ���������ʼʱ�̵ļ��ٶȣ������ڳ������ȼ�����ǵ������λ�á�
            %����ζ���ʽ����
            %����ZMP����ζ���ʽ����
            px_init=0;   vpx_init=0; apx_init=0;  px_end=px(Kn+K+1,1);   vpx_end=(px(Kn+K+2,1)-px(Kn+K+1,1))/dt; apx_end=0; 
            py_init=0;   vpy_init=0; apy_init=0;  py_end=py(Kn+K+1,1);   vpy_end=(py(Kn+K+2,1)-py(Kn+K+1,1))/dt; apy_end=0; 
            
            ax(n_int,:)=[1,0,0,0,0,0; 1,DSP(n_int),(DSP(n_int))^(2),(DSP(n_int))^(3),(DSP(n_int))^(4),(DSP(n_int))^(5);...
                          0,1,0,0,0,0; 0,1,2*DSP(n_int),3*(DSP(n_int))^(2),4*(DSP(n_int))^(3),5*(DSP(n_int))^(4);...
                          0,0,2,0,0,0; 0,0,2,6*DSP(n_int),12*(DSP(n_int))^(2),20*(DSP(n_int))^(3)  ]\[px_init;px_end;vpx_init;vpx_end;apx_init;apx_end];
            a0x=ax(n_int,1);  a1x=ax(n_int,2);a2x=ax(n_int,3);a3x=ax(n_int,4);a4x=ax(n_int,5);a5x=ax(n_int,6);
            
            ay(n_int,:)=[1,0,0,0,0,0; 1,DSP(n_int),(DSP(n_int))^(2),(DSP(n_int))^(3),(DSP(n_int))^(4),(DSP(n_int))^(5);...
                          0,1,0,0,0,0; 0,1,2*DSP(n_int),3*(DSP(n_int))^(2),4*(DSP(n_int))^(3),5*(DSP(n_int))^(4);...
                          0,0,2,0,0,0; 0,0,2,6*DSP(n_int),12*(DSP(n_int))^(2),20*(DSP(n_int))^(3)  ]\[py_init;py_end;vpy_init;vpy_end;apy_init;apy_end];
             a0y=ay(n_int,1);  a1y=ay(n_int,2);a2y=ay(n_int,3);a3y=ay(n_int,4);a4y=ay(n_int,5);a5y=ay(n_int,6);         
            for i=1:K
           %����ʽ�����
            px(Kn+i,1)= a0x+a1x*(i*dt)+a2x*(i*dt)^2+a3x*(i*dt)^3+a4x*(i*dt)^4+a5x*(i*dt)^5;   %ע���Ѿ���ȫ������ϵ
            py(Kn+i,1)= a0y+a1y*(i*dt)+a2y*(i*dt)^2+a3y*(i*dt)^3+a4y*(i*dt)^4+a5y*(i*dt)^5;   %ע���Ѿ���ȫ������ϵ   ˫����ZMP��ζ���ʽ��ֵ
            end      
         %���Ҫ��һ�仰����ĩ״̬���¸�ֵΪ�����ڵ�ĩ״̬��Ϊ��һ���ڵ�˫�������ʼ״̬��
            x_end(n_int)=(Sx(n_int)-10*DSP(n_int)*length)/2;               
            y_end(n_int)=(-1)^(n_int)*(Sy(n_int)-10*DSP(n_int)*width)/2;
            Vx_end(n_int)= Tc*coth(Tc*SSP(n_int)/2)*x_end(n_int);
            Vy_end(n_int)= Tc*tanh(Tc*SSP(n_int)/2)*y_end(n_int);              
        else   %��һ�����ں������
            %%%%�����Դ���˫����%%%%%%%%%%
            T_int=T_int+T;
            Kn=round(T_int/dt);
            %---���ζ���ʽ��ֵ�ı߽�����
            %�ֲ�����ϵ��λ��------
            footx(n_int)=footx(n_int-1)+Sx(n_int-1);
            footy(n_int)=footy(n_int-1)+(-1)^(n_int-1)*Sy(n_int-1);
            K=round(DSP(n_int)/dt);   
            %%%%%%%%%��������������������������������������������%%%%%%%%
            %Ϊ���㵥������������Ӧ������Ӧ���ص�滮�����࣬
            %���嵥�����ʼ��ĩ����λ�ú��ٶȣ��ȶ��嵥����ĩ��λ�ú��ٶ�
            x_end(n_int)=(Sx(n_int)-10*DSP(n_int)*length)/2;                %�������ڵĲ����й�
            y_end(n_int)=(-1)^(n_int)*(Sy(n_int)-10*DSP(n_int)*width)/2;    %�������ڵĲ����й�            
            Vx_end(n_int)= Tc*coth(Tc*SSP(n_int)/2)*x_end(n_int);
            Vy_end(n_int)= Tc*tanh(Tc*SSP(n_int)/2)*y_end(n_int);  
            %�������ʼʱ��-----------
            x_init(n_int)=-x_end(n_int);              %���Գ�
            y_init(n_int)=y_end(n_int);               %���Գ�
            Vx_init(n_int)= Vx_end(n_int);
            Vy_init(n_int)=-Vy_end(n_int);           
            %=======������,��С�������ƣ��������==
            Kssp=round(SSP(n_int)/dt);
            D_T=calcu_D_T(Tc,SSP(n_int));
            E_AT=calcu_E_AT(Tc,SSP(n_int));            
            %��������������,����ʱ��Ϊt_adjust
            
            if n_int==3
                if t_adjust<=DSP(n_int)
                    for i=1:Kssp
                    px(Kn+K+i,1)=[sinh(Tc*i*dt),cosh(Tc*i*dt)]*D_T*([x_end(n_int);Vx_end(n_int)]-E_AT*[x_init(n_int);Vx_init(n_int)])+footx(n_int);   %ע��ת�Ƶ�ȫ������ϵ��
                    py(Kn+K+i,1)=[sinh(Tc*i*dt),cosh(Tc*i*dt)]*D_T*([y_end(n_int);Vy_end(n_int)]-E_AT*[y_init(n_int);Vy_init(n_int)])+footy(n_int);   %ע��ת�Ƶ�ȫ������ϵ��
                    det_time=i*dt;   %%%ϵͳʱ��
                    S_t=calcu_S_T(Tc,det_time);
                    E_At=calcu_E_AT(Tc,i*dt);
                    Rx(Kn+K+i,:)=E_At*[x_init(n_int);Vx_init(n_int)]+S_t*D_T*([x_end(n_int);Vx_end(n_int)]-E_AT*[x_init(n_int);Vx_init(n_int)])/2;
                    Ry(Kn+K+i,:)=E_At*[y_init(n_int);Vy_init(n_int)]+S_t*D_T*([y_end(n_int);Vy_end(n_int)]-E_AT*[y_init(n_int);Vy_init(n_int)])/2;
                    x(Kn+K+i,1)=Rx(Kn+K+i,1) +footx(n_int); %ע��ת�Ƶ�ȫ������ϵ��
                    y(Kn+K+i,1)=Ry(Kn+K+i,1) +footy(n_int);  %ע��ת�Ƶ�ȫ������ϵ
                    Vx(Kn+K+i,1)=Rx(Kn+K+i,2);
                    Vy(Kn+K+i,1)=Ry(Kn+K+i,2);
                    end
                else
                    tN=round((t_adjust-DSP(n_int))/dt);
                    T_ad=T-t_adjust;
                    %ǰһ��ʱ�䲻���е���
                    for i=1:tN
                    px(Kn+K+i,1)=[sinh(Tc*i*dt),cosh(Tc*i*dt)]*D_T*([x_end(n_int);Vx_end(n_int)]-E_AT*[x_init(n_int);Vx_init(n_int)])+footx(n_int);   %ע��ת�Ƶ�ȫ������ϵ��
                    py(Kn+K+i,1)=[sinh(Tc*i*dt),cosh(Tc*i*dt)]*D_T*([y_end(n_int);Vy_end(n_int)]-E_AT*[y_init(n_int);Vy_init(n_int)])+footy(n_int);   %ע��ת�Ƶ�ȫ������ϵ��
                    det_time=i*dt;
                    S_t=calcu_S_T(Tc,det_time);
                    E_At=calcu_E_AT(Tc,i*dt);
                    Rx(Kn+K+i,:)=E_At*[x_init(n_int);Vx_init(n_int)]+S_t*D_T*([x_end(n_int);Vx_end(n_int)]-E_AT*[x_init(n_int);Vx_init(n_int)])/2;
                    Ry(Kn+K+i,:)=E_At*[y_init(n_int);Vy_init(n_int)]+S_t*D_T*([y_end(n_int);Vy_end(n_int)]-E_AT*[y_init(n_int);Vy_init(n_int)])/2;
                    x(Kn+K+i,1)=Rx(Kn+K+i,1) +footx(n_int); %ע��ת�Ƶ�ȫ������ϵ��
                    y(Kn+K+i,1)=Ry(Kn+K+i,1) +footy(n_int);  %ע��ת�Ƶ�ȫ������ϵ
                    Vx(Kn+K+i,1)=Rx(Kn+K+i,2);
                    Vy(Kn+K+i,1)=Ry(Kn+K+i,2);
                    end     
                    D_T=calcu_D_T(Tc,T_ad);
                    E_AT=calcu_E_AT(Tc,T_ad);
                    %�����Ͳ��������
%                     Sx(n_int)=Sx(n_int)+50;
%                     Sy(n_int)=Sy(n_int)-50;
                    x_end(n_int)=(Sx(n_int)-10*DSP(n_int)*length)/2;                %�������ڵĲ����й�
                    y_end(n_int)=(-1)^(n_int)*(Sy(n_int)-10*DSP(n_int)*width)/2;    %�������ڵĲ����й�            
                    Vx_end(n_int)= Tc*coth(Tc*SSP(n_int)/2)*x_end(n_int);
                    Vy_end(n_int)= Tc*tanh(Tc*SSP(n_int)/2)*y_end(n_int);                     
                    %��һ��ʱ�俪ʼ������ŵ�
                    for i=(tN+1):Kssp
                    det_time=(i-tN)*dt;
                    px(Kn+K+i,1)=[sinh(Tc*det_time),cosh(Tc*det_time)]*D_T*([x_end(n_int);Vx_end(n_int)]-E_AT*[x_init(n_int);Vx(Kn+K+tN,1)])+footx(n_int);   %ע��ת�Ƶ�ȫ������ϵ��
                    py(Kn+K+i,1)=[sinh(Tc*det_time),cosh(Tc*det_time)]*D_T*([y_end(n_int);Vy_end(n_int)]-E_AT*[y_init(n_int);Vy(Kn+K+tN,1)])+footy(n_int);   %ע��ת�Ƶ�ȫ������ϵ��
                    end                                                                                    
                end
            else   
                for i=1:Kssp
                px(Kn+K+i,1)=[sinh(Tc*i*dt),cosh(Tc*i*dt)]*D_T*([x_end(n_int);Vx_end(n_int)]-E_AT*[x_init(n_int);Vx_init(n_int)])+footx(n_int);   %ע��ת�Ƶ�ȫ������ϵ��
                py(Kn+K+i,1)=[sinh(Tc*i*dt),cosh(Tc*i*dt)]*D_T*([y_end(n_int);Vy_end(n_int)]-E_AT*[y_init(n_int);Vy_init(n_int)])+footy(n_int);   %ע��ת�Ƶ�ȫ������ϵ��
                end  
            end
            %---˫����ʼ��ĩZMPλ�ú��ٶ�, 
            %����ζ���ʽ����
            %����ZMP����ζ���ʽ����
            px_init=px(Kn,1);   vpx_init=(px(Kn,1)-px(Kn-1,1))/dt; apx_init=0;  px_end=px(Kn+K+1,1);   vpx_end=(px(Kn+K+2,1)-px(Kn+K+1,1))/dt; apx_end=0; 
            py_init=py(Kn,1);   vpy_init=(py(Kn,1)-py(Kn-1,1))/dt; apy_init=0;  py_end=py(Kn+K+1,1);   vpy_end=(py(Kn+K+2,1)-py(Kn+K+1,1))/dt; apy_end=0; 
            
            ax(n_int,:)=[1,0,0,0,0,0; 1,DSP(n_int),(DSP(n_int))^(2),(DSP(n_int))^(3),(DSP(n_int))^(4),(DSP(n_int))^(5);...
                          0,1,0,0,0,0; 0,1,2*DSP(n_int),3*(DSP(n_int))^(2),4*(DSP(n_int))^(3),5*(DSP(n_int))^(4);...
                          0,0,2,0,0,0; 0,0,2,6*DSP(n_int),12*(DSP(n_int))^(2),20*(DSP(n_int))^(3)  ]\[px_init;px_end;vpx_init;vpx_end;apx_init;apx_end];
            a0x=ax(n_int,1);  a1x=ax(n_int,2);a2x=ax(n_int,3);a3x=ax(n_int,4);a4x=ax(n_int,5);a5x=ax(n_int,6);
            
            ay(n_int,:)=[1,0,0,0,0,0; 1,DSP(n_int),(DSP(n_int))^(2),(DSP(n_int))^(3),(DSP(n_int))^(4),(DSP(n_int))^(5);...
                          0,1,0,0,0,0; 0,1,2*DSP(n_int),3*(DSP(n_int))^(2),4*(DSP(n_int))^(3),5*(DSP(n_int))^(4);...
                          0,0,2,0,0,0; 0,0,2,6*DSP(n_int),12*(DSP(n_int))^(2),20*(DSP(n_int))^(3)  ]\[py_init;py_end;vpy_init;vpy_end;apy_init;apy_end];
             a0y=ay(n_int,1);  a1y=ay(n_int,2);a2y=ay(n_int,3);a3y=ay(n_int,4);a4y=ay(n_int,5);a5y=ay(n_int,6);         
            for i=1:K
           %����ʽ�����
            px(Kn+i,1)= a0x+a1x*(i*dt)+a2x*(i*dt)^2+a3x*(i*dt)^3+a4x*(i*dt)^4+a5x*(i*dt)^5;   %ע���Ѿ���ȫ������ϵ
            py(Kn+i,1)= a0y+a1y*(i*dt)+a2y*(i*dt)^2+a3y*(i*dt)^3+a4y*(i*dt)^4+a5y*(i*dt)^5;   %ע���Ѿ���ȫ������ϵ
            end                  
        end
    end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%���Ĵ��У�������ʱ�����̵�ZMP������⡣
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pz=736*ones(XN,1);
[~, ~, ~, v,comx,comy]=ZMP2COM(t,px,py,pz);
for i=1:K
    x(Kn+i,1)=comx(i,:);
    y(Kn+i,1)=comy(i,:);
end    
x=comx;
y=comy;
Vx=v(1,:)';
Vy=v(2,:)';

%------------��ͼ---    
    figure(1)
    hold on;
    plot(footx(1:N,:),footy(1:N,:),'r');
    plot(px(1:XN,:),py(1:XN,:),'--');
    plot(x(1:XN,:),y(1:XN,:),'g');
    legend('�������ص�','ZMPλ��','���Ĺ켣');
    xlabel('x(mm)');ylabel('y(mm)');
   
    figure(2)
    subplot(2,1,1);
    plot(t,Vx(1:XN,:));
    xlabel('t(s)');ylabel('Vx(mm/s)');
    subplot(2,1,2);
    plot(t,Vy(1:XN,:));
    xlabel('t(s)');ylabel('Vy(mm/s)');   
    
    figure(3)
    subplot(2,2,1);
    plot(t,x(1:XN,:));
    xlabel('t(s)');ylabel('x(mm/s)');
    subplot(2,2,2);
    plot(t,y(1:XN,:));
    xlabel('t(s)');ylabel('y(mm/s)'); 
    subplot(2,2,3);
    plot(t,px(1:XN,:));
    xlabel('t(s)');ylabel('px(mm/s)');
    subplot(2,2,4);
    plot(t,py(1:XN,:));
    xlabel('t(s)');ylabel('py(mm/s)');    

end

function E_AT=calcu_E_AT(Tc,Tsup)
   E_AT=[cosh(Tc*Tsup),   (sinh(Tc*Tsup))/Tc;...
        Tc*sinh(Tc*Tsup), cosh(Tc*Tsup)];
end

function D_T=calcu_D_T(Tc,Tsup)
D_T=2/(sinh((Tc*Tsup)^2)-(Tc*Tsup)^2)*[Tc*Tsup*cosh(Tc*Tsup)+sinh(Tc*Tsup),  -Tsup*sinh(Tc*Tsup);-Tc*Tsup*sinh(Tc*Tsup),(Tc*Tsup*cosh(Tc*Tsup)-sinh(Tc*Tsup))/Tc];
end

function S_T=calcu_S_T(Tc,Tsup)
S_T=[sinh(Tc*Tsup)-Tc*Tsup*cosh(Tc*Tsup),  -Tc*Tsup*sinh(Tc*Tsup);...
     -(Tc)^2*Tsup*sinh(Tc*Tsup),           -(Tc*Tsup*cosh(Tc*Tsup)+sinh(Tc*Tsup))/Tc];
end

%%
 function [comx,comy]=three_mass_ZMP_COM(px,py,num,mB,mL,T,dt)  %%num-������������������������λ�Ʋ��������ҽŵĵ�����
%%%�������ʵ㣬���ݹ滮��ZMP�Լ��㲿�켣��������λ��,����ѭ����Ӧ�����¶׵����
N=length(px);
M=mB+2*mL;
M_c=mB+mL;
w=sprt((mB+mL)*g/(M*Ez));
Nt=T/dt;
x_B=zeros(N);
y_B=zeros(N); %��������λ������
 px_ini=zeros(num);
 py_ini=zeros(num);
 px_end=zeros(num);
 py_end=zeros(num);
for i=1:1:num
    px_ini(i)=px(Nt*(i-1)+1);
    py_ini=py(Nt*(i-1)+1);
    px_end=px(Nt*i);
    py_end=py(Nt*i);
end

[Ax,Bx,Ay,By]=three_mass_model_parameter_resolution(px_ini,py_ini,px_end,py_end,T,px,py);%%���ʵ����ϵ��

 for i=1:1:num   %%�����ڽ��м���
    for k=1:1:Nt
    tr=dt*i;
    Ft=diff(add,tr);%%�˴���function
    xB((i-1)*Nt+k)=Ax(i)*exp(-w*tr)+Bx(i)*exp(w*tr)+M*(Ft-Ex)/M_c;   %%����λ�ü���
    yB((i-1)*Nt+k)=Ay(i)*exp(-w*tr)+By(i)*exp(w*tr)+M*(Ft-Ex)/M_c;
    end
 end
comx=x_B;
comy=y_B;
 end

%%
function [Ax,Bx,Ay,By]=three_mass_model_parameter_resolution(px,py,T,dt,num,M,Xs,Ys)  
%================���ݱ߽�����ȷ������ֵ===================%
%%LIPM������ʼĩ����λ�ã�x=
Ax=zeros(1,1,num);
Ay=zeros(1,1,num);
Bx=zeros(1,1,num);
By=zeros(1,1,num);
Nt=T/dt;
% x_B=zeros(N);
% y_B=zeros(N); %��������λ������
% px_ini=zeros(1,1,num);
% py_ini=zeros(1,1,num);
% px_end=zeros(1,1,num);
% py_end=zeros(1,1,num);
% for i=1:1:num
%     px_ini(i)=px(Nt*(i-1)+1);
%     py_ini(i)=py(Nt*(i-1)+1);
%     px_end(i)=px(Nt*i);
%     py_end(i)=py(Nt*i);
%  end
[dfx_ini,dfx_end,dfy_ini,dfy_end]=resolution_ZMP(px,py,Xs,Ys,mL,mB,t,M);
[Ex,Ey,~]=parameter_cal(mB,mL,Zc,stepx,stepy);
    for j=1:1:num

    xB_end=(Sx(j)-10*DSP*length)/2;  %%??
    xB_ini=-xB_end;
    Ax(j)=(xB_ini*exp(w*T)-xB_end+M*(dfx_end(j)-Ex)/mc-exp(w*T)*M*(dfx_ini(j)-Ex)/mc)/(exp(w*T)-exp(-w*T));
    Ay(j)=(yB_ini*exp(w*T)-yB_end+M*(dfy_end(j)-Ey)/mc-exp(w*T)*M*(dfy_ini(j)-Ey)/mc)/(exp(w*T)-exp(-w*T));
    Bx(j)=(xB_end-xB_ini*exp(-w*T)+M*(dfx_end(j)-Ex)/mc-exp(-w*T)*M*(dfx_ini(j)-Ex)/mc)/(exp(w*T)-exp(-w*T));
    By(j)=(yB_end-yB_ini*exp(-w*T)+M*(dfy_end(j)-Ey)/mc-exp(-w*T)*M*(dfy_ini(j)-Ey)/mc)/(exp(w*T)-exp(-w*T));
    end
end
%%  -----------------------------------------------
function [dfx_ini,dfx_end,dfy_ini,dfy_end]=resolution_ZMP(px,py,Xs,Ys,mL,M,t)  %%ZMP����COM��������ڳ�ʼλ����Ϣ������΢�ַ��̲���Ax��Ay��Bx��By
dXs=Diff(t,Xs);   %%ע���㲿λ�õ�ά��
ddXs=Diff(t,dXs);
dYs=Diff(t,Ys);
ddYs=Diff(t,dYs);
Fx=px-mL*(Xs-Zs*ddXs/g)/(2*M);
Fy=py-mL*(Ys-Zs*ddYs/g)/(2*M);
dFx=Diff(t,Fx);
dFy=Diff(t,Fy);

dfx_ini=zeros(num,1);
dfy_ini=zeros(num,1);
dfx_end=zeros(num,1);
dfy_end=zeros(num,1);

 for i=1:1:num
     dfx_ini(i)=dFx(Nt*(i-1)+1);
     dfy_ini(i)=dFy(Nt*(i-1)+1);
     dfx_end(i)=dFx(Nt*i);
     dfy_end(i)=dFy(Nt*i);
 end

 
end
%%
function [Ex,Ey,Ez]=parameter_cal(mB,mL,Zc,stepx,stepwidth)  %%�򻯲�������
[Zs,Zw,Cxt,Cxs,Ysp,Ysw]=position_threemass_leg_com(Zc,stepx,stepwidth);

Ex=(mB*CxB+mL*Cxs+mL*Cxw)/(mB+mL*2);
Ey=(mB*CyB+mL*Cys+mL*Cyw)/(mB+mL*2);
Ez=(mB*Zc+mL*Zs/2+mL*Zw/2)/(mB+mL*2);
        function [Zs,Zw,Cxs,Cxw,Ysp,Ysw]=position_threemass_leg_com(Zc,stepx,stepwidth,mB,mL)  %%�����ʼ�¶���̬֧����/Zs,�ڶ���/Zw���ĸ߶� �����ڷ��滷��ֱ�Ӳ���
        %ͨ���������˶�ѧ����
        end
    
%%�¶���̬������λ�á���̬
[t_goal,comx,comy,comz,Rp,RR,Rv,Rw,Lp,LR,Lv,Lw]=plan_com(dt,num,stepwidth,stepx);
bodyp1=[comx;comy;comz];
t=t_goal;
N1=length(t);
if palse==1
    Initial(N1);
    for pii=1:2 %���forѭ�������������ZMP��ѭ������Ϊ��������
        %-----��������������ҽŵ�λ�á�--------
    bodyp2=bodyp1';
    bodyp=reshape(bodyp1,[3,1,N1]);
    [bp,bR,bv,bw]=trans_bp(bodyp,t,N1);%trans�����bodyp��Ȼ����ά����
    Link(1).p=bp;Link(1).R=bR;Link(1).v=bv;Link(1).w=bw;
    R_RefpR.v=Rv;R_RefpR.w=Rw;R_RefpR.p=Rp;R_RefpR.R=RR;
    L_RefpR.v=Lv;L_RefpR.w=Lw;L_RefpR.p=Lp;L_RefpR.R=LR;
    Forward_Kinematics(2,N1);
    InverseKinematics(6,R_RefpR);
    InverseKinematics(11,L_RefpR);
    com=calCom();%������������
    [totZMP,ZMP_body]=cal_linkZMP(com,R_RefpR,L_RefpR,t);
    [del_com,~,zmpdesign]=cal_del_x(totZMP,t,comx,comy);

    bodyp=bodyp+reshape(del_com,3,1,[]);%delc-comԭΪ��ά����ת��Ϊ��ά����
    end 
    c=zeros(N1,10);
    for j=2:11
        c(:,j-1)=Link(j).q(:);%Nx10
    end
    y=c;
end
end
%%

function [bodyp1,bodyp,bodyv,v,comx,comy]=ZMP2COM(rt,px,py,pz)
%scatter:��ɢ 
%parameters
Zc=736;%���滹һ��!!!!cal_del_x
%tde=6;%��ʼ�¶����Ƶ�ʱ��
g=9800;%��λ��mm/s^2
dt=rt(2)-rt(1);
% if stnum~=0
%     dohead=3;
% else dohead=0;
% end
%t=rt(1)-dohead:dt:rt(end)+0.5;%���Է��֣������벻ͬ��ZMP��ʱ��������ɢ�㷨��ԭ��
t=rt(1):dt:rt(end);
%�غ϶���ͬ��ʱ��������λ�Ʋ�ͬ������,0:2��2:4��2sʱ�������в������ķ�������
%���˸���һ��ʱ�䣬��ȡ�м��ʱ�䡣
a=-Zc/(g*dt^2);
b=2*Zc/(g*dt^2)+1;
c=-Zc/(g*dt^2);
N=length(t);
diag_1=ones(N,1)*b;
diag_2=ones(N-1,1)*c;
diag_3=ones(N-1,1)*a;
diag_1(1)=a+b;diag_1(end)=b+c;
A=diag(diag_2,1)+diag(diag_1)+diag(diag_3,-1);
%[px py com_z]=Design_ZMP(t);
vx=Diff(t,px);
px(1)=px(1)+a*vx(1)*dt;
px(end)=px(end)-a*vx(end)*dt;
com_x=A\px;
vy=Diff(t,py);
py(1)=py(1)+a*vy(1)*dt;
py(end)=py(end)-a*vy(end)*dt;
com_y=A\py;
vz=Diff(t,pz);
pz(1)=pz(1)+a*vz(1)*dt;
pz(end)=pz(end)-a*vz(end)*dt;
com_z=A\pz;
bodyp1=[com_x com_y com_z]';
%������,change to 3_D array
bodyp=reshape(bodyp1,[3,1,N]);
%repmat���Ը��ƾ���repmat(eye(3),[1,N])
bodyv=Diff(t,bodyp);%Diff�Ѹ���ʱ�̵�p������һ��������ά������󵼺��ʱ�䡣
picst=find(abs(t-rt(1))<0.0001);
picen=find(abs(t-rt(end))<0.0001);
comx=com_x(picst:picen,:);
comy=com_y(picst:picen,:);
bodyp1=bodyp1(:,picst:picen);
bodyp=bodyp(:,:,picst:picen);
bodyv=bodyv(:,:,picst:picen);
v=reshape(bodyv,[3,N]);
end   %%��������������ֵ����������λ��

%%
function [Lp,LR,Lv,Lw,Rp,RR,Rv,Rw]=FootpR(t,footx1,footy1,T_ini,dt,SSP,DSP)
%-------------parameter
%ע�⣬�����t�ļ���Ĵﵽ0.005,0.001����û����
%���������ص�fw�ǽ��ٶ�ʸ����fv���ٶ�ʸ����p��ÿһ����һ��ʱ����p��
%R��ÿһ����һ��ʱ����R����Ҫ��reshape(R(:,i),[3,3])����ԭ
%����㳤�ȡ�
b1=100;
%ǰ���㳤�ȡ�
b2=100;
T=DSP(1,1)+SSP(1,1);
%������ע�������塣
th1=2*pi/180; 
%���ʱ���������ļнǡ�
th2=2*pi/180;
%-----------------------------------�滮���䲽�����㲿�켣-----------------------------
%���� footx1��ά��ȷ�������㲿�İڶ����������ڹ滮�ģ���һ��������Ϊ���λ�ã�ʵ���˶���һ�����ҽ�Ҫ�ֶ��滮����ż��Ϊ�ҽ�λ�á�
tN=length(t);

K=length(footx1);    
    %�𲽽׶Σ��ҽ�������һ��
    RLorRini=-130;   %%�ѿ�������ϵ������Ϊx������������Ϊ������
    RFirststep=(RLorRini+footy1(2,:))/2;
    Rstep=footy1(2,:);
    LLorRini=130;
    LFirststep=(LLorRini+footy1(3,:))/2;
    Lstep=footy1(3,:);       
    Rt_plan=[dt,1.2,T_ini-2*T,T_ini-T,T_ini-2*DSP(1,1),T_ini-DSP(1,1)/2];  
    Rfoot_plan=[[0;RLorRini;0],[0;RLorRini;0],[b2*(1-cos(th2));RLorRini;b2*sin(th2)],[footx1(2,:)/2;RFirststep;15],...
        [footx1(2,:)-b1*(1-cos(th1));Rstep;b1*sin(th1)],[footx1(2,:);Rstep;0]];
    Rangle_plan=[0,0,th2,th2/2,th1,0];
    %�� T_ini~T_ini+T֮�����������һ��
    Lt_plan=[dt,T_ini,T_ini+DSP(2,1),T_ini+DSP(2,1)+0.2,T_ini+DSP(2,1)+SSP(2,1)/2,T_ini+T-0.02,T_ini+T];
    Lfoot_plan=[[0;LLorRini;0],[0;LLorRini;0],[0;LLorRini;0],[b2*(1-cos(th2));LLorRini;b2*sin(th2)],[footx1(2,:);LFirststep;15],...
        [footx1(3,:)-b1*(1-cos(th1));Lstep;b1*sin(th1)],[footx1(3,:);Lstep;0]];
    Langle_plan=[0,0,0,th2,th2/2,-th1,0]; 
   %ע��position_ZMP_COM_energymin_footplace.m�㲿��ŵ������е�����������ŵĵ�һ����ŵ㣬���ĸ������ҽŵĵڶ�����ŵ�
 for i=4:K
     if rem(i,2)==0  %�ҽ�
         Rt_plan=[Rt_plan,(T_ini+fix((2*i-5)/2)*T),(T_ini+fix((2*i-5)/2)*T+DSP((i-1),:)),(T_ini+fix((2*i-5)/2)*T+DSP((i-1),:)+0.02),...
             (T_ini+fix((2*i-5)/2)*T+DSP((i-1),:)+SSP((i-1),:)/2),(T_ini+fix((2*i-3)/2)*T-0.02),(T_ini+fix((2*i-3)/2)*T),(T_ini+fix((2*i-3)/2)*T)+DSP((i),:)];
         Rfoot_plan=[Rfoot_plan,[footx1(i-2,:);footy1(i-2,:);0],[footx1(i-2,:);footy1(i-2,:);0],...
             [footx1(i-2,:)+b2*(1-cos(th2));footy1(i-2,:);b2*sin(th2)],[footx1(i-1,:);(footy1(i,:)+footy1(i-2,:))/2;40],[footx1(i,:)-b1*(1-cos(th1));footy1(i,:);b1*sin(th1)],[footx1(i,:);footy1(i,:);0],[footx1(i,:);footy1(i,:);0]];
         Rangle_plan=[Rangle_plan,0,0,th2,th2/2,-th1,0,0];
     else            %���
         Lt_plan=[Lt_plan,(T_ini+fix((2*i-5)/2)*T),(T_ini+fix((2*i-5)/2)*T+DSP((i-1),:)),(T_ini+fix((2*i-5)/2)*T+DSP((i-1),:)+0.02),...
             (T_ini+fix((2*i-5)/2)*T+DSP((i-1),:)+SSP((i-1),:)/2),(T_ini+fix((2*i-3)/2)*T-0.02),(T_ini+fix((2*i-3)/2)*T),(T_ini+fix((2*i-3)/2)*T)+DSP(i,:)];
         Lfoot_plan=[Lfoot_plan,[footx1(i-2,:);footy1(i-2,:);0],[footx1(i-2,:);footy1(i-2,:);0],...
             [footx1(i-2,:)+b2*(1-cos(th2));footy1(i-2,:);b2*sin(th2)],[footx1(i-1,:);(footy1(i,:)+footy1(i-2,:))/2;40],[footx1(i,:)-b1*(1-cos(th1));footy1(i,:);b1*sin(th1)],[footx1(i,:);footy1(i,:);0],[footx1(i,:);footy1(i,:);0]];
         Langle_plan=[Langle_plan,0,0,th2,th2/2,-th1,0,0];         
     end
 end
 Rfoot_pp=pchip(Rt_plan,Rfoot_plan);%���ˣ�pp��3x1�ľ������зֱ�Ϊgait p��x��y��z
 R_aa=pchip(Rt_plan,Rangle_plan);
 Lfoot_pp=pchip(Lt_plan,Lfoot_plan);
 L_aa=pchip(Lt_plan,Langle_plan);
 Rfoot=ppval(Rfoot_pp,t);
 Lfoot=ppval(Lfoot_pp,t);

 %�ҽŵĲ��� 
Rq2w=ppval(R_aa,t);%�����Ƕ�
Rq2w=reshape(Rq2w,[1,1,tN]);
RR=Rodrigues([0 1 0],Rq2w); %%��ת����
Rpbm=reshape( Rfoot,[3,1,tN]);
Rp=Rpbm-sum(bsxfun(@times,RR,repmat([0 0 -122],[1,1,tN])),2);
Rv=Diff(t,Rp);
Rw=bsxfun(@times,repmat([0 1 0]',[1,1,tN]),Diff(t,Rq2w));%foot��w����,������Ҫ��ȡ��fnder������fw��һ����������Ϊlength(t)
Rw=reshape(Rw,[3,1,tN]); 

%��Ų��� 
Lq2w=ppval(L_aa,t);%�����Ƕ�
Lq2w=reshape(Lq2w,[1,1,tN]);
LR=Rodrigues([0 1 0],Lq2w);
Lpbm=reshape( Lfoot,[3,1,tN]);
Lp=Lpbm-sum(bsxfun(@times,LR,repmat([0 0 -122],[1,1,tN])),2);
Lv=Diff(t,Lp);
Lw=bsxfun(@times,repmat([0 1 0]',[1,1,tN]),Diff(t,Lq2w));%foot��w����,������Ҫ��ȡ��fnder������fw��һ����������Ϊlength(t)
Lw=reshape(Lw,[3,1,tN]); 
end

%%
function Forward_Kinematics(j,tN)
global Link;
%j=2��������ֵ,global��ֵ���ᱻ�ͷţ���Ҫ��command�и���global Link
%�˶�ѧ������Ҫ���ɵĳ�ʼ����
if j==0 
    return;
end
if j~=1
    i=Link(j).motherID;%����ı�����ע�ͣ�sum����Ϊ�˰�b��Ϊ��ά���鲢��R���,ע��b��ת�����⡣����ĵڶ���һ����������
    %��Ϊ��@times�Ƕ�ӦԪ����ˣ����ж�Ӧ���С��������õ��ĸ����˵�R����3x3xN����pΪ3x1xN��
    %Link(i).p+Link(i).R*Link(j).b;
    Link(j).p=Link(i).p+sum(bsxfun(@times,Link(i).R,repmat(Link(j).b',[1,1,tN])),2);
    %Link(j).R=Link(i).R*Rodrigues(Link(j).a, Link(j).q);
    %ע�������p��R�Ѿ���j�������������ϵ��λ�ú���̬����Ϊĸ�������p��R
    %�Ƕ���������ģ����൱��0Tj=0Ti * iTj
    %�������䣨��end��������ʵ������3x3xN�������ڵ���ά�����
    temR=repmat(Link(i).R,[],3);
    rot=Rodrigues(Link(j).a,Link(j).q);
    rot2=permute(rot,[2 1 3]);
    [m,~,~]=size(rot2);
    idx=1:m;
    idx=idx(ones(1,3),:);
    rot3=rot2(idx(:),:,:);
    tem=sum(bsxfun(@times,temR,rot3),2);
    Link(j).R=reshape(tem,[3,3,tN]);
end
Forward_Kinematics(Link(j).brotherID,tN);
Forward_Kinematics(Link(j).childID,tN);
end
%%
function InverseKinematics(TargetID, posRef)
%TargetID��posRef�ֱ���Ŀ��˵�ID����ο�λ�ˣ�����p��R��
global Link;
%�������ؽڽǶȳ�ֵ,�������0��jacobian������״̬��
ray=Target_ray(TargetID);
N=16;%������������
[~,~,tN]=size(Link(1).p);
delta_q=zeros(5,1,tN);
for n=1:N
    J=CalJacobian(ray);
    err=CalErr(TargetID,posRef);
    %--------------�������������--------
%     if norm(err)<1E-5
%         %mark=1;
%         Forward_Kinematics(2);
%     end
%         break;
%     %������ȣ������delta_q=0.5*J\err;
%     delta_q=0.5*pinv(J)*err;
%     for nn=2:length(ray)
%         j=ray(nn);
%         Link(j).q=Link(j).q+delta_q(nn-1);
%     end
%     Forward_Kinematics(2);
%     -----------------------------------��Ҫ����
      if norm(err(:))<1E-3  %�жϾ���
          break;
      end
      %delta_q=0.5*J\err(:);%deltaq��һ��������ÿN����һ���ؽڵ�����ʱ�̣�������5N
      for i1=1:length(J(1,1,:))%ȡ����ά�ĳ���
          delta_q(:,:,i1)=J(:,:,i1)\err(:,:,i1)*0.5;
      end
      %delta_q=reshape(delta_q,[],tN);
      for nn=2:length(ray)
          j=ray(nn);
          Link(j).q=Link(j).q+delta_q(nn-1,:,:);
      end
       Forward_Kinematics(2,tN);
end
%----------Traget_ray�������������ɵ�Ŀ�����˵�ID����
    function ray=Target_ray(TargetID)
     i=Link(TargetID).motherID;
     if i==1
         ray=[1;TargetID];
     else
         ray=[Target_ray(i);TargetID];% ray = 1 2 3
     end
    end
%------CalJacobian()���������ɵ�Ŀ��������N����֮����Ÿ�Ⱦ���(6*N)
    function J=CalJacobian(ray)
        pn=Link(ray(end)).p;
        %------------������---------------------
        jN=length(ray);
        j2=zeros(6,1,tN);j3=zeros(6,1,tN);j4=zeros(6,1,tN);j5=zeros(6,1,tN);
        j6=zeros(6,1,tN);%eval���ֵı�����Ҫ��eval֮ǰ���ڡ�
        %   �й��Ż���1:��J�Ƿ�Ӧ��������һ��2��j�����һ�У�������pn-pn,ֱ��д��0
        for i=2:jN   
            a=sum(bsxfun(@times,Link(ray(i)).R,repmat(Link(ray(i)).a',[1,1,tN])),2);%aҪΪ������
            eval(['j' int2str(i) '=[cross(a,pn-Link(ray(i)).p);a];']);               %cross���Դ�����ά�ġ�;Ҳ���ԣ��������Ǹ������õ�
        end
        J=[j2,j3,j4,j5,j6];%J  6x5xN,N��ʾʱ��,6x5��ʾ��5���ؽڽǶȡ�
    end
%------------����λ�����ĺ�����p��R(w)�����
    function err=CalErr(TargetID,PosRef)
        dp=PosRef.p-Link(TargetID).p;
        %����������һ��
        %dw=Link(TargetID).R*R2W(Link(TargetID).R'*PosRef.R);
        forR=array3D_multi(permute(Link(TargetID).R,[2 1 3]),PosRef.R);
        tem1=permute(R2W(forR),[2 1 3]);
        dw=sum(bsxfun(@times,Link(TargetID).R,tem1),2);
        err=[dp;dw];%6x1xn
    end
%------------��̬�����ٶȵ�ת������������̬������
    function w=R2W(dR)%�ж����������Ƿ���ȣ�Ҫ������ֵ����Ҫ��==
        %-------------������---------------
        tol=1e-004;
        E=repmat(eye(3),[1,1,tN]);
        temr=max(max(dR(:,:,:)-E(:,:,:)));
        ray0=find(temr(:)<tol);
        w(:,:,ray0)=zeros(3,1,length(ray0));%��ʼ������1��tN���ҳ�E����¼�Ǳ굽ray0
        temray=1:tN;temray(ray0)=[];ray1=temray;%��1��tN�ĽǱ��зǵ�λ��ĽǱ�ŵ�ray1
        tem1=dR(1,1,ray1)+dR(2,2,ray1)+dR(3,3,ray1);
        thta=acos((tem1-1)/2);%1x1xN
        tem2=bsxfun(@rdivide,thta,2*sin(thta));
        tem3=[dR(3,2,ray1)-dR(2,3,ray1);dR(1,3,ray1)-dR(3,1,ray1);dR(2,1,ray1)-dR(1,2,ray1)];
        w(:,:,ray1)=bsxfun(@times,tem2,tem3);
%         if norm(dR-eye(3))<1e-004;
%             w=[0 0 0]';
%         else
%             thta=acos((sum(diag(dR))-1)/2);
%             w=thta/(2*sin(thta))*[dR(3,2)-dR(2,3);dR(1,3)-dR(3,1);dR(2,1)-dR(1,2)];
%         end
    end
    function R=array3D_multi(R1,R2)%����3x3xN�ľ����ڵ���ά���
        tR1=repmat(R1,[],3);
        tR2=permute(R2,[2 1 3]); 
        [m,~,tN]=size(tR2);
        idx=1:m;
        idx=idx(ones(1,3),:);
        ttR2=tR2(idx(:),:,:);
        tem=sum(bsxfun(@times,tR1,ttR2),2);
        R=reshape(tem,[3,3,tN]);
    end
end
%%
function [ del_com,del_p,zmpdesign] = cal_del_x(zmpreal,t,comx,comy)
Zc=736;
g=9800;%��λ����������mm/s^2
comx_v=Diff(t,comx); %%��һ��΢��
comy_v=Diff(t,comy);
comx_acc=Diff(t,comx_v);
comy_acc=Diff(t,comy_v);
zmpdesignx=comx-Zc/g*comx_acc;     %%��Ϊ������zmp���㷽��
zmpdesigny=comy-Zc/g*comy_acc;     %%��Ϊ������zmp���㷽��
zmpdesign=[zmpdesignx;zmpdesigny];%%��һ��x���ڶ���y
del_p=zmpdesign-zmpreal;
%--------------------------A
dt=t(2)-t(1);
a=-Zc/(g*dt^2);
b=2*Zc/(g*dt^2)+1;
c=-Zc/(g*dt^2);
N=length(t);
diag_1=ones(N,1)*b;
diag_2=ones(N-1,1)*c;
diag_3=ones(N-1,1)*a;
diag_1(1)=a+b;diag_1(end)=b+c;
A=diag(diag_2,1)+diag(diag_1)+diag(diag_3,-1);
%-----------------------A-end
del_comx=A\del_p(1,:)';%���Ϊ������ 
del_comy=A\del_p(2,:)';
del_comz=zeros(length(t),1);
del_com=[del_comx,del_comy,del_comz]';%��һ��x���ڶ���y
end
%%
function [bp,bodyR,bodyv,bodyw]=trans_bp(bodyp,t,N)  %%��������תʸ�������䣩���ٶȡ����ٶȣ��ޣ�
bp=bodyp;
bodyR=reshape(repmat(eye(3),[1,N]),[3,3,N]);
bodyv=Diff(t,bodyp);
bodyw=kron([0 0 0]',ones(1,length(t)));
bodyw=reshape(bodyw,[3,1,N]);
end
%%
function com=calCom(~)%%������������
%�ó��򷵻��������ģ���ʽΪ3*N
global Link;
    function mc=calmc(j)
        if j==0
            mc=0;
        else
            %mcΪ����������������ϵ������λ�ã��ֲ�����1Ϊ������һ�ˣ���������ϵ��������ĸˡ�
            %����������һ��
            %mc=Link(j).m*(Link(j).p+Link(j).R*Link(j).c);
            Link(j).mc=Link(j).p+sum(bsxfun(@times,Link(j).R,Link(j).c),2);
            mc=Link(j).m*Link(j).mc;
            mc=mc+calmc(Link(j).brotherID)+calmc(Link(j).childID);
        end
    end
    function M=TotalMass(j)
        if j==0
            M=0;
        else
            m=Link(j).m;
            M=m+TotalMass(Link(j).brotherID)+TotalMass(Link(j).childID);
        end
    end
Mc=calmc(1);%1->j
com=Mc./TotalMass(1);
com=reshape(com,3,[]);
end   
%%
function [ ZMPall ZMPl1 ] = cal_linkZMP(c,Rflink,Lflink,t)
%�ó��򷵻�����ZMP������ZMP����ʽ��Ϊ2*N����һ��ΪX���ꡣ
global Link N;
pz=0;
g=9800;%���ﵥλ��mm,kg,s,��gӦȡΪmm/s^2��mN/kg
[P L]=calPL(Rflink,Lflink);
M=TotalMass(1);
% % % % % %------------------------�ɿ�����Polyfit���������P��L�õ�������
dP=Diff(t,P);
dL=Diff(t,L);
allpx = (M*g*c(1,:)+pz*dP(1,:)-dL(2,:))./(M*g+dP(3,:));
allpy = (M*g*c(2,:)+pz*dP(2,:)+dL(1,:))./(M*g+dP(3,:));
ZMPall=[allpx;allpy];
%-----------------------����ZMP������-----------------------
%-----------------------����ZMP-------------------------------
dPl1=Diff(t,reshape(Link(1).P,3,[]));
dLl1=Diff(t,reshape(Link(1).L,3,[]));
m=Link(1).m;
cc=reshape(Link(1).mc,3,[]);
zmpl1x = (m*g*cc(1,:)+pz*dPl1(1,:)-dLl1(2,:))./(m*g+dPl1(3,:));
zmpl1y = (m*g*cc(2,:)+pz*dPl1(2,:)+dLl1(1,:))./(m*g+dPl1(3,:));
ZMPl1=[zmpl1x;zmpl1y];
%------------------------����ZMP����--------------------------
    function [P L]=calPL(Rflink,Lflink)%������˵�PL���������ܵ�PL(3*N�ľ���)
        %�������ҽ�ΪĿ�����˵�����dq���������ܵ����ٶȺ������������и˵��ٶȣ�
        Caldq(6,Rflink);%��TargetID_R
        Caldq(11,Lflink);%��TargetID_L
        ForwardVelocity(2);%���˸����˵��ٶȣ����Լ���L��P
        P=reshape(calP(1),3,[]);
        L=reshape(calL(1),3,[]);
        function ForwardVelocity(j)
        if j==0
            return;
        end
        if j~=1
            i=Link(j).motherID;
            %Link(j).v=Link(i).v+cross(Link(i).w,Link(i).R*Link(j).b);
            %Link(j).w=Link(i).w+Link(i).R*Link(j).a*Link(j).dq;%����dq
            %������
            tempRb=sum(bsxfun(@times,Link(i).R,repmat(Link(j).b',[1,1,N])),2);
            Link(j).v=Link(i).v+cross(Link(i).w,tempRb);
            tempRa=sum(bsxfun(@times,Link(i).R,repmat(Link(j).a',[1,1,N])),2);
            Link(j).w=Link(i).w+bsxfun(@times,tempRa,Link(j).dq);
        end
        ForwardVelocity(Link(j).brotherID);
        ForwardVelocity(Link(j).childID);
        end
        function P=calP(j)
        if j==0;
            P=0;
        else
            %tempc=Link(j).R*Link(j).c;
            %P=Link(j).m*(Link(j).v+cross(Link(j).w,tempc));
            %P=P+calP(Link(j).brotherID)+calP(Link(j).childID);
            tempRc=sum(bsxfun(@times,Link(j).R,Link(j).c),2);
            Link(j).P=Link(j).m*(Link(j).v+cross(tempRc,Link(j).w));
            P=Link(j).P;
            P=P+calP(Link(j).brotherID)+calP(Link(j).childID);
        end
        end
        function L=calL(j)
        if j==0;
            L=0;
        else
            %tempc=Link(j).R*Link(j).c;
            %p=Link(j).m*(Link(j).v+cross(Link(j).w,tempc));
            %L=cross(Link(j).c,p)+Link(j).R*Link(j).I*Link(j).R'*Link(j).w;
            %L=L+calL(Link(j).brotherID)+calL(Link(j).childID);
            tempRI=array3D_multi(Link(j).R,Link(j).I);
            tempRIRt=array3D_multi(tempRI,permute(Link(j).R,[2 1 3]));
            Link(j).L=cross(permute(Link(j).c,[2 1 3]),Link(j).P)+sum(bsxfun(@times,tempRIRt,Link(j).w),2);
            L=Link(j).L;
            L=L+calL(Link(j).brotherID)+calL(Link(j).childID);       
        end
        end
        function Caldq(TargetID,flink)%�����flinkֻ�ṩ�ο����ٶȺͽ��ٶ�;��������
        vb=Link(1).v;
        wb=Link(1).w;
        vt=flink.v;
        wt=flink.w;
        vd=vt-vb-cross(wb,(flink.p-Link(1).p));
        wd=wt-wb;
        %JACOBIAN
        ray=Target_ray(TargetID);
        J=CalJacobian(ray);
        vw=[vd;wd];
        dq=zeros(5,1,length(vw));
        for izm=1:length(J(1,1,:))%ȡ����ά�ĳ���
          dq(:,:,izm)=J(:,:,izm)\vw(:,:,izm);
        end
        %��ֵ�ڸ�����
        for qi=2:length(ray)
            j=ray(qi);
            Link(j).dq=dq(qi-1,:,:);%J 2 3 4 5 6
        end
        end
        function ray=Target_ray(TargetID)
     i=Link(TargetID).motherID;
     if i==1
         ray=[1;TargetID];
     else
         ray=[Target_ray(i);TargetID];% ray = 1 2 3
     end
        end
        function J=CalJacobian(ray)         %�ſɱȾ������
            pn=Link(ray(end)).p;
            %------------������---------------------
            jN=length(ray);
            j2=zeros(6,1,N);j3=zeros(6,1,N);j4=zeros(6,1,N);j5=zeros(6,1,N);
            j6=zeros(6,1,N);%eval���ֵı�����Ҫ��eval֮ǰ���ڡ�
        %   �й��Ż���1:��J�Ƿ�Ӧ��������һ��2��j�����һ�У�������pn-pn,ֱ��д��0
            for i=2:jN   
                a=sum(bsxfun(@times,Link(ray(i)).R,repmat(Link(ray(i)).a',[1,1,N])),2);%aҪΪ������
                eval(['j' int2str(i) '=[cross(a,pn-Link(ray(i)).p);a];']);               %cross���Դ�����ά�ġ�;Ҳ���ԣ��������Ǹ������õ�
            end
            J=[j2,j3,j4,j5,j6];%J  6x5xN,N��ʾʱ��,6x5��ʾ��5���ؽڽǶȡ�
        end
        function R=array3D_multi(R1,R2)
        tR1=repmat(R1,[],3);
        tR2=permute(R2,[2 1 3]);
        [m,~,tN]=size(tR2);
        idx=1:m;
        idx=idx(ones(1,3),:);
        ttR2=tR2(idx(:),:,:);
        tem=sum(bsxfun(@times,tR1,ttR2),2);
        R=reshape(tem,[3,3,tN]);
       end
    end 
    function M=TotalMass(j)         %������������
        if j==0
            M=0;
        else
            m=Link(j).m;
            M=m+TotalMass(Link(j).brotherID)+TotalMass(Link(j).childID);
        end
    end
end
%%
function [ e_out ]=Rodrigues(a,q)       %�ѵ�λʸ����ת��a��Ϊñ�Ӿ���б�Գƾ���,������ת����
                            
%e_out����ά����3x3xN��a��ʸ����3x1��q����άʸ����1x1xN
a_skew=zeros(3,3);
a_skew(1,2)=-a(3);
a_skew(1,3)=a(2);
a_skew(2,3)=-a(1);
a_skew=-a_skew'+a_skew;
%����ת��������Rodriguesʽ
%����expmЧ�ʣ���ȥexpm���Ա�expm
%e_out=expm(a_skew*q);%������expm��
RN=length(q);%Ҫ��q��һ��1x1xN����ά����
%e_out=eye(3)+a_skew*sin(q)+a_skew^2*(1-cos(q));
%-------------������,������ʵ����ʽ
a_skew1=repmat(a_skew,[1,1,RN]);
a_skew2=repmat(a_skew^2,[1,1,RN]);
%sq=reshape(sin(q)',[1,1,RN]);Initial��qŪ����ά�������ˡ�
sq=sin(q);
%cq_1=reshape(1-cos(q)',[1,1,RN]);
cq_1=1-cos(q);
factor2=bsxfun(@times,a_skew1,sq);%sq������
factor3=bsxfun(@times,a_skew2,cq_1);%cq_1������
e_out=repmat(eye(3),[1,1,RN])+factor2+factor3;
end

%%
function dy=Diff(x,y)
        if length(size(y))==3
            [a,~,b]=size(y);
            y=reshape(y,[a,b]);
            cs=csapi(x,y);
            pp1=fnder(cs);
            dy=fnval(pp1,x);
            dy=reshape(dy,[a,1,b]);
        else 
            cs=csapi(x,y);          %������������
            pp1=fnder(cs);          %������������΢��
            dy=fnval(pp1,x);        %�����ڸ����㴦����������ֵ
        end
end