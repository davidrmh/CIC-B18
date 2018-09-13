/* Program for calculating European Call Option price using Monte Carlo
simulation and Black-Scholes formula.

How to compile:

g++ -I /usr/local/include/gsl/ -o monte_carlo_black_scholes-openmp monte_carlo_black_scholes.cpp
 -lgsl -lgslcblas -lm -fopenmp

*/
#include<stdio.h>
#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>
#include<math.h>
#include <vector>
#ifdef _OPENMP
  #include <omp.h>
#endif
using namespace std;

const double PI = 3.141592653589793;
const double a0 = 2.50662823884;
const double a1 = -18.61500062529;
const double a2 = 41.39119773534;
const double a3 = -25.44106049637;
const double b1 =  -8.47351093090;
const double b2 = 23.08336743743;
const double b3 = -21.06224101826;
const double b4 = 3.13082909833;
const double c0 = 0.3374754822726147;
const double c1 = 0.9761690190917186;
const double c2 = 0.1607979714918209;
const double c3 = 0.0276438810333863;
const double c4 = 0.0038405729373609;
const double c5 = 0.0003951896511919;
const double c6 = 0.0000321767881768;
const double c7 = 0.0000002888167364;
const double c8 = 0.0000003960315187;

// Horner function (overloading)

//h0
double hornerFunction(double x, double a0){
  return a0;
}

//h1
double hornerFunction(double x, double a0, double a1){
  return a0 + x*hornerFunction(x,a1);
}

double hornerFunction(double x,double a0, double a1, double a2){
  return a0 + x*hornerFunction(x, a1, a2);
}

double hornerFunction(double x,double a0, double a1, double a2, double a3){
  return a0 + x*hornerFunction(x, a1, a2, a3);
}

double hornerFunction(double x,double a0, double a1, double a2, double a3, double a4){
  return a0 + x*hornerFunction(x, a1, a2, a3, a4);
}

double hornerFunction(double x,double a0, double a1, double a2, double a3, double a4, double a5){
  return a0 + x*hornerFunction(x, a1, a2, a3, a4, a5);
}

double hornerFunction(double x,double a0, double a1, double a2, double a3, double a4, double a5, double a6){
  return a0 + x*hornerFunction(x, a1, a2, a3, a4, a5, a6);
}

double hornerFunction(double x,double a0, double a1, double a2, double a3, double a4, double a5, double a6, double a7){
  return a0 + x*hornerFunction(x, a1, a2, a3, a4, a5, a6, a7);
}

double hornerFunction(double x,double a0, double a1, double a2, double a3, double a4, double a5, double a6, double a7, double a8){
  return a0 + x*hornerFunction(x, a1, a2, a3, a4, a5, a6, a7, a8);
}

//Normal cumulative distribution function
//x a double in (-infty, infty)
double normcdf(double x){
  double k, N;

  if(x >= 0){
    k = 1/(1 + 0.2316419*x);
    N=1-(1/sqrt(2*PI))*exp(-1*pow(x,2)/2)*k*(0.319381530+k*(-0.356563782+k*(1.781477937+k*(-1.821255978+1.330274429*k))));
    return N;

  }

  else{
    return 1 - normcdf(-x);
  }
}

//Inverse Normal cumulative distribution function
// x a double in [0,1]
double norminv(double x){
  double y, r, h3, h4, t, s, z;
  y = x -0.5;

  if(fabs(x) < 0.42){
    r = pow(y,2);
    h3 = hornerFunction(r, a0, a1, a2, a3);
    h4 = hornerFunction(r, 1.0, b1, b2, b3, b4);
    z = y*h3/h4;
    return z;
  }
  else{
    if(y < 0){r = x;}
    else{r = 1-x;}
    s = log(-1*log(r));
    t = hornerFunction(s, c0, c1, c2, c3, c4, c5, c6, c7, c8);
    if(x > 0.5){return t;}
    else{return -1*t;}
  }

}

//Black Scholes close formula
// double S0 stock price
// double K strike price
// double r risk free interest rate
// double sigma volatility
// double T time to maturity
double blackscholesCallPrice(double s0, double k, double r, double sigma, double T){
  double d1, d2, N1, N2, call;

  d1 = 1/(sigma * sqrt(T)) * (log(s0 / k) + (r + 0.5*pow(sigma,2) * sqrt(T)));
  d2 = 1/(sigma * sqrt(T)) * (log(s0 / k) + (r - 0.5*pow(sigma,2) * sqrt(T)));

  N1 = normcdf(d1);
  N2 = normcdf(d2);
  call = N1 * s0 - N2*k*exp(-r*T);
  return call;

}

int main(int argc, char *argv[]){

  //Counters
  int i,h;

  //GSL random number generator
  const gsl_rng_type * T;
  gsl_rng *r;
  T = gsl_rng_default;
  r = gsl_rng_alloc(T);

  //number of simulations
  const long num_sim = 1000000;

  //number of time-steps
  const long num_steps = 252;

  //Time tu maturity
  const double maturity = 1.0;

  //time step size
  const double delta_t  = maturity / num_steps;

  //mu, sigma and strike
  double mu = 0.04, sigma = 0.2, k = 110;

  //s0
  double s0 = 100;

  //random number from a normal distribution
  double z;

  //payoff
  double payoff_sim = 0, payoff_bs = 0;

  //here I store each simulation
  //The initial price is equal to 100
  vector < vector<double> > simulations(num_sim, vector<double>(num_steps, s0) );

  double t_aux;
  #pragma omp parallel for private(i, h, z) num_threads(100)
  for(i = 0; i < num_sim; i++){
    for(h = 0; h < num_steps; h++){
      z = gsl_ran_gaussian(r, 1.0);
      t_aux = (h + 1)*delta_t;
      simulations[i][h+1] = s0 * exp( (mu - 0.5 * pow(sigma,2))*t_aux + sigma*sqrt(t_aux)*z );
    }

    //Calculates call payoff and accumulates so we can later obtain the average
    payoff_sim = payoff_sim + fmax(simulations[i][num_steps - 1] - k, 0);
    //printf("Final value is %.4f \n", simulations[i][num_steps - 1]);
  }

  //simulated payoff
  payoff_sim = payoff_sim / num_sim;

  //exact payoff
  payoff_bs = blackscholesCallPrice(s0, k, mu, sigma, maturity);

  printf("The simulated payoff is %.4f \n", payoff_sim);
  printf("The Black-Scholes value is %.4f \n", payoff_bs);

  return 0;
}
