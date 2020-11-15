import numpy as np
from scipy.integrate import odeint
import matplotlib.pyplot as plt
    
def massspring(X, t):
    x = X[0]
    y = X[1]
    dxdt = y
    dydt = -x - 0.5*y
    return [dxdt, dydt]

# initial condition
X0 = [1.0, 0.0]

# time points
t = np.linspace(0, 30, 200)

# solve ODE
sol = odeint(massspring, X0, t)

# plot results
x = sol[:, 0]
y = sol[:, 1]

plt.plot(t,x, t, y)
plt.xlabel('t')
plt.legend(('x', 'y'))
#plt.show()
plt.savefig('massspring.png')

# phase portrait
plt.figure()
plt.plot(x,y)
plt.plot(x[0], y[0], 'ro')
plt.xlabel('x')
plt.ylabel('y')
#plt.show()
plt.savefig('massspring2.png')