from sympy.solvers import solve
from sympy import Symbol, evalf

x = Symbol('x')
answer = solve(x**3+2*x**2 +3*x+1, x)
print(answer)
for i in range(len(answer)):
    print(answer[i].evalf())
