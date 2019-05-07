#include<iostream>
#include <cmath>  
#include <cstdio>  
#include <cstdlib>

using namespace std;

class Line//ax+by=1 ����������,��ԭ��ʱc=0
    {
	public :double a ;
	public :double b ;
	public :double c ;
    };
class Point
    {
	public :double Y ;
	public :double X ;
	public :double r ;//��ָ����ľ���
    };
static Point call_c(double jd, double wd, double s_1, double s_2, double s_3, double s_4, double x_len, double y_len, double angle, double A, double N);
static Point rotatePoint(Point p0, double angle, double jd, double wd);
static Point distanceAndPoint(double single, double A, double N, double x, double y);
static Point getLocationByFour(Point p1, Point p2, Point p3, Point p4);
static Point getLocationByThree(Point p1, Point p2, Point p3);
static Point getPointByTwoLine(Line L1, Line L2);
static Line getLineByTwoCircle(Point p1, Point p2);

static double value [11];
static Point pointOut;
int main(int argc, char*argv[])
{
	int a;
	//cout<<"�������в���"<<endl;
	//cin>>value[0]>>value[1]>>value[2]>>value[3]>>value[4]>>value[5]>>value[6]>>value[7]>>value[8]>>value[9]>>value[10];
	//cout<<argv[2]<<endl;
	if(argc>=12)
	{
		for(a=0;a<11;a++)
		{
			value[a] = atof(argv[a+1]);
		}
		pointOut = call_c(value[0], value[1], value[2], value[3], value[4], value[5], value[6], value[7], value[8], value[9], value[10]);
		cout<<pointOut.X<<","<<pointOut.Y<<endl;
	}
	return 0;
}

static Point call_c(double jd, double wd, double s_1, double s_2, double s_3, double s_4, double x_len, double y_len, double angle, double A, double N)
{
    //���ź�ǿ��ת��Ϊ���롢�궨��
    /* �ĵ㶨λ
     * s1(0,y)    x         s2(x,y)
     * 
     * y                    y
     * 
     * s3(0,0)    x         s4(x,0)
     */

    Point p1 = distanceAndPoint(s_1, A, N, 0.0, y_len);
    Point p2 = distanceAndPoint(s_2, A, N, x_len, y_len);
    Point p3 = distanceAndPoint(s_3, A, N, 0.0, 0.0);
    Point p4 = distanceAndPoint(s_4, A, N, x_len, 0.0);
    /*
    Point p1 = new Point() { X = 0.0, Y = y_len, r = s_1 };
    Point p2 = new Point() { X = x_len, Y = y_len, r = s_2 };
    Point p3 = new Point() { X = 0.0, Y = 0.0, r = s_3 };
    Point p4 = new Point() { X = x_len, Y = 0.0, r = s_4 };
    */
    //�ĵ㶨λ
    Point p = getLocationByFour(p1, p2, p3, p4);
    p = rotatePoint(p, angle, jd, wd);
    return p;
}

static Point rotatePoint(Point p0, double angle, double jd, double wd)
{
    double anglePI = angle * 3.1415927 / 180;
    Point p;
    p.X = p0.X * cos(anglePI) + p0.Y * sin(anglePI) + jd;
    p.Y = p0.Y * cos(anglePI) - p0.X * sin(anglePI) + wd;
    p.r = p0.r;
    return p;
}

static Point distanceAndPoint(double single, double A, double N, double x, double y)//���ź�ǿ��ת��Ϊ���롢�궨��
{
    Point p;
    double lenth = 0;
    lenth = A * exp(0 - single * N);//ָ��˥�� a*e^(-n*x)
    //lenth = A - 10 * N * Math.Log10(single);//A-10*n*lgr
    p.r = lenth;
    p.X = x;
    p.Y = y;
    return p;
}

// �ĵ㶨λ��������㶨λ
static Point getLocationByFour(Point p1, Point p2, Point p3, Point p4)
{
    Point p;
    Point P4 = getLocationByThree(p1, p2, p3);
    Point P3 = getLocationByThree(p1, p2, p4);
    Point P2 = getLocationByThree(p1, p3, p4);
    Point P1 = getLocationByThree(p2, p3, p4);
    p.X = (P1.X + P2.X + P3.X + P4.X) / 4;
    p.Y = (P1.Y + P2.Y + P3.Y + P4.Y) / 4;
    p.r = 0;
    return p;
}

//���㶨λ
static Point getLocationByThree(Point p1, Point p2, Point p3)
{
    //������Բ���ߣ��ҵ�������
    Line L12 = getLineByTwoCircle(p1, p2);
    Line L23 = getLineByTwoCircle(p2, p3);
    Line L31 = getLineByTwoCircle(p3, p1);
    //�����������󽻵�  ����״̬��ֻ��һ������
    Point p13 = getPointByTwoLine(L12, L23);
    Point p21 = getPointByTwoLine(L23, L31);
    Point p32 = getPointByTwoLine(L31, L12);
    //����������ƽ��       ��ֹ����ƫ��
    Point p;
    p.X = (p13.X + p32.X + p21.X) / 3;
    p.Y = (p13.Y + p32.Y + p21.Y) / 3;
    p.r = 0;
    return p;
}

//�����ҵ�
static Point getPointByTwoLine(Line L1, Line L2)
{
    Point p ;
    double a1 = L1.a;
    double b1 = L1.b;
    double c1 = L1.c;
    double a2 = L2.a;
    double b2 = L2.b;
    double c2 = L2.c;
    if (a1 * b2 != a2 * b1)
    {
        p.X = (c1 * b2 - c2 * b1) / (a1 * b2 - a2 * b1);
        p.Y = (c1 * a2 - c2 * a1) / (b1 * a2 - b2 * a1);
    }
    else//////ƽ�У���ʵ�ڴ˴����ᷢ����
    {
        if (a1 != 0)
        {
            p.X = 1 / a1;
        }
        else
        {
            p.X = 1 / a2;
        }
        if (b1 != 0)
        {
            p.Y = 1 / b1;
        }
        else
        {
            p.Y = 1 / b2;
        }
    }
    p.r = 0;
    return p;
}

//��Բ����
static Line getLineByTwoCircle(Point p1, Point p2)//��Բ��������
{
    Line l ;
    Point p ;
    double r1 = p1.r;//�뾶
    double r2 = p2.r;
    double bili = 0.5;
    double dd = pow(p1.X - p2.X, 2) + pow(p1.Y - p2.Y, 2);
    double d = sqrt(dd);//����֪������  >0
    double xs = p2.X - p1.X;//����֪���X����
    double ys = p2.Y - p1.Y;//����֪���Y����
    if (r1 + r2 > d)//�������н���
    {
        double rr1 = r1 * r1;
        double rr2 = r2 * r2;
        double len = (rr1 - rr2 + dd) / 2 / d;  //��Բ�������ĵ���һ����ľ���
        bili = len / d;//����
        p.r = sqrt(rr1 - len * len);
    }
    else
    {
        bili = r1 / (r1 + r2);
    }
    p.X = bili * xs + p1.X;
    p.Y = bili * ys + p1.Y;
    if (xs != 0)//����y=kx+b
    {
        double k = ys / xs;
        if ((p.X + k * p.Y) != 0)
        {
            double a = 1 / (p.X + k * p.Y);
            double b = a * k;
            l.a = a;
            l.b = b;
            l.c = 1;
        }
        else//��ԭ��
        {
            l.c = 0;
            l.a = 1;
            l.b = 1 * k;
        }
    }
    else//  ����x=y/k-b/k
    {
        double k_ = xs / ys;//      1/k
        if ((k_ * p.X + p.Y) != 0)
        {
            double b = 1 / (k_ * p.X + p.Y);
            double a = b * k_;
            l.a = a;
            l.b = b;
            l.c = 1;
        }
        else//��ԭ��
        {
            l.c = 0;
            l.b = 1;
            l.a = 1 * k_;
        }
    }

    return l;
}

