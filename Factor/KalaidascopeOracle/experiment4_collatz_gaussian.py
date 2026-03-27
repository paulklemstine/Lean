"""
EXPERIMENT 4: Collatz Dynamics on Gaussian Integers
===================================================
Extend the Collatz map to ℤ[i] (Gaussian integers):
  If n ≡ 0 (mod 1+i): C(n) = n / (1+i)
  Otherwise: C(n) = (1+i)*n + 1

Study: orbit lengths, convergence, fractal structure.
"""

class GaussianInt:
    """Gaussian integer a + bi."""
    def __init__(self, a, b=0):
        self.a = a
        self.b = b
    
    def __add__(self, other):
        return GaussianInt(self.a + other.a, self.b + other.b)
    
    def __sub__(self, other):
        return GaussianInt(self.a - other.a, self.b - other.b)
    
    def __mul__(self, other):
        return GaussianInt(
            self.a * other.a - self.b * other.b,
            self.a * other.b + self.b * other.a
        )
    
    def norm(self):
        return self.a * self.a + self.b * self.b
    
    def __eq__(self, other):
        return self.a == other.a and self.b == other.b
    
    def __hash__(self):
        return hash((self.a, self.b))
    
    def __repr__(self):
        if self.b == 0:
            return str(self.a)
        elif self.a == 0:
            return f"{self.b}i"
        elif self.b > 0:
            return f"{self.a}+{self.b}i"
        else:
            return f"{self.a}{self.b}i"
    
    def divmod_1pi(self):
        """Divide by (1+i). Returns (quotient, remainder) if exact, else None."""
        # (a+bi)/(1+i) = (a+bi)(1-i)/2 = ((a+b) + (b-a)i)/2
        real_part = self.a + self.b
        imag_part = self.b - self.a
        if real_part % 2 == 0 and imag_part % 2 == 0:
            return GaussianInt(real_part // 2, imag_part // 2), True
        return None, False

ONE_PLUS_I = GaussianInt(1, 1)
ONE = GaussianInt(1, 0)

def gaussian_collatz(z, max_iter=1000):
    """Iterate Gaussian Collatz map. Returns orbit."""
    orbit = [z]
    for _ in range(max_iter):
        if z.norm() <= 2:  # close to convergence
            break
        quot, divisible = z.divmod_1pi()
        if divisible:
            z = quot
        else:
            z = ONE_PLUS_I * z + ONE
        
        if z in orbit:
            # Found a cycle
            cycle_start = orbit.index(z)
            return orbit, cycle_start
        orbit.append(z)
        
        if z.norm() > 10**8:  # diverging
            return orbit, -2  # diverged
    
    return orbit, -1  # converged

print("=" * 80)
print("EXPERIMENT 4: COLLATZ ON GAUSSIAN INTEGERS")
print("=" * 80)
print()

# Survey orbits for small Gaussian integers
print("Orbit analysis for Gaussian integers a+bi, |a|,|b| ≤ 10:")
print()

cycle_census = {}
convergent = 0
divergent = 0
cyclic = 0

for a in range(-10, 11):
    for b in range(-10, 11):
        if a == 0 and b == 0:
            continue
        z = GaussianInt(a, b)
        orbit, status = gaussian_collatz(z, max_iter=500)
        
        if status == -1:  # converged
            convergent += 1
        elif status == -2:  # diverged
            divergent += 1
        else:  # cyclic
            cyclic += 1
            cycle = tuple(orbit[status:])
            cycle_key = frozenset(cycle)
            if cycle_key not in cycle_census:
                cycle_census[cycle_key] = {'cycle': cycle, 'count': 0, 'examples': []}
            cycle_census[cycle_key]['count'] += 1
            if len(cycle_census[cycle_key]['examples']) < 3:
                cycle_census[cycle_key]['examples'].append(z)

print(f"Total starting points: {21*21 - 1}")
print(f"Convergent (norm → small): {convergent}")
print(f"Divergent (norm → ∞): {divergent}")
print(f"Cyclic: {cyclic}")
print(f"Distinct cycles found: {len(cycle_census)}")

print("\nCycles found:")
for ck, info in sorted(cycle_census.items(), key=lambda x: -x[1]['count']):
    print(f"  Cycle (length {len(info['cycle'])}): {list(info['cycle'])[:8]}...")
    print(f"    Attracted {info['count']} points, e.g., {info['examples']}")
    print()

# Study norm dynamics
print("\nNorm trajectories for selected starting points:")
test_points = [GaussianInt(3, 4), GaussianInt(7, 0), GaussianInt(5, 5), 
               GaussianInt(2, 7), GaussianInt(1, 1)]

for z0 in test_points:
    orbit, status = gaussian_collatz(z0, max_iter=100)
    norms = [z.norm() for z in orbit[:30]]
    print(f"  {z0}: norms = {norms[:15]}... (length={len(orbit)}, status={'conv' if status==-1 else 'div' if status==-2 else f'cycle@{status}'})")

# Alternative: Collatz with different multiplier
print("\n\nALTERNATIVE: Collatz with multiplier (2+i) instead of (1+i):")
TWO_PLUS_I = GaussianInt(2, 1)

def gaussian_collatz_v2(z, max_iter=500):
    orbit = [z]
    for _ in range(max_iter):
        if z.norm() <= 2:
            break
        # Check divisibility by 2 (as Gaussian integer)
        if z.a % 2 == 0 and z.b % 2 == 0:
            z = GaussianInt(z.a // 2, z.b // 2)
        else:
            z = TWO_PLUS_I * z + ONE
        
        if z.norm() > 10**8:
            return orbit, -2
        if z in orbit:
            return orbit, orbit.index(z)
        orbit.append(z)
    return orbit, -1

conv2 = div2 = cyc2 = 0
for a in range(-8, 9):
    for b in range(-8, 9):
        if a == 0 and b == 0:
            continue
        orbit, status = gaussian_collatz_v2(GaussianInt(a, b))
        if status == -1: conv2 += 1
        elif status == -2: div2 += 1
        else: cyc2 += 1

print(f"  Convergent: {conv2}, Divergent: {div2}, Cyclic: {cyc2}")
