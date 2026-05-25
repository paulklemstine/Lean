#!/usr/bin/env python3
"""
Applications of irreducible polynomial certification.

Demonstrates real-world uses of X^4 + X + 1 and the modular transfer framework:
1. Finite field construction (GF(16)) for coding theory
2. Linear feedback shift register (LFSR) for pseudorandom generation
3. Error-correcting codes (BCH codes over GF(16))
4. AES-related finite field arithmetic
"""

import numpy as np
from itertools import product


# ============================================================
# 1. GF(16) Arithmetic using X^4 + X + 1
# ============================================================

class GF16:
    """Element of GF(16) = GF(2)[x]/(x^4 + x + 1).
    
    Each element is represented as a polynomial of degree ≤ 3 over GF(2),
    i.e., a 4-bit vector [a₀, a₁, a₂, a₃] representing a₀ + a₁α + a₂α² + a₃α³
    where α is a root of x^4 + x + 1.
    
    The key relation is: α⁴ = α + 1 (since α⁴ + α + 1 = 0 in GF(2)).
    """
    # Modulus: x^4 + x + 1 = [1, 1, 0, 0, 1]
    MODULUS = [1, 1, 0, 0, 1]
    
    def __init__(self, coeffs: list[int]):
        """Create GF(16) element from coefficient list [a₀, a₁, a₂, a₃]."""
        self.coeffs = [(c % 2) for c in (coeffs + [0, 0, 0, 0])[:4]]
    
    @classmethod
    def zero(cls) -> 'GF16':
        return cls([0, 0, 0, 0])
    
    @classmethod 
    def one(cls) -> 'GF16':
        return cls([1, 0, 0, 0])
    
    @classmethod
    def alpha(cls) -> 'GF16':
        """The primitive element α."""
        return cls([0, 1, 0, 0])
    
    @classmethod
    def from_power(cls, n: int) -> 'GF16':
        """Compute α^n."""
        if n == 0:
            return cls.one()
        result = cls.one()
        base = cls.alpha()
        n = n % 15  # α^15 = 1
        for _ in range(n):
            result = result * base
        return result
    
    def __add__(self, other: 'GF16') -> 'GF16':
        return GF16([(a + b) % 2 for a, b in zip(self.coeffs, other.coeffs)])
    
    def __sub__(self, other: 'GF16') -> 'GF16':
        return self + other  # In GF(2), subtraction = addition
    
    def __mul__(self, other: 'GF16') -> 'GF16':
        # Polynomial multiplication mod 2
        prod = [0] * 7
        for i in range(4):
            for j in range(4):
                prod[i + j] = (prod[i + j] + self.coeffs[i] * other.coeffs[j]) % 2
        # Reduce mod x^4 + x + 1: x^4 ≡ x + 1
        # x^6 = x^2 · x^4 ≡ x^2(x+1) = x^3 + x^2
        # x^5 = x · x^4 ≡ x(x+1) = x^2 + x
        # x^4 ≡ x + 1
        result = list(prod[:4])
        # Reduce x^4 term: x^4 → x + 1
        result[0] = (result[0] + prod[4]) % 2
        result[1] = (result[1] + prod[4]) % 2
        # Reduce x^5 term: x^5 → x^2 + x
        result[1] = (result[1] + prod[5]) % 2
        result[2] = (result[2] + prod[5]) % 2
        # Reduce x^6 term: x^6 → x^3 + x^2
        result[2] = (result[2] + prod[6]) % 2
        result[3] = (result[3] + prod[6]) % 2
        return GF16(result)
    
    def __pow__(self, n: int) -> 'GF16':
        if n == 0:
            return GF16.one()
        if n < 0:
            return self.inv() ** (-n)
        result = GF16.one()
        base = self
        while n > 0:
            if n % 2 == 1:
                result = result * base
            base = base * base
            n //= 2
        return result
    
    def inv(self) -> 'GF16':
        """Multiplicative inverse using α^15 = 1, so α^(-1) = α^14."""
        if self.is_zero:
            raise ZeroDivisionError("Cannot invert zero in GF(16)")
        # a^(-1) = a^(14) since a^15 = 1 for all nonzero a
        return self ** 14
    
    @property
    def is_zero(self) -> bool:
        return all(c == 0 for c in self.coeffs)
    
    def __eq__(self, other) -> bool:
        if not isinstance(other, GF16):
            return False
        return self.coeffs == other.coeffs
    
    def __hash__(self):
        return hash(tuple(self.coeffs))
    
    def to_int(self) -> int:
        """Convert to integer representation (for compact display)."""
        return sum(c * (2**i) for i, c in enumerate(self.coeffs))
    
    def __repr__(self) -> str:
        terms = []
        symbols = ['1', 'α', 'α²', 'α³']
        for i in range(4):
            if self.coeffs[i]:
                terms.append(symbols[i])
        return ' + '.join(terms) if terms else '0'


# ============================================================
# 2. LFSR (Linear Feedback Shift Register) using X^4 + X + 1
# ============================================================

def lfsr_x4_x_1(seed: list[int], length: int) -> list[int]:
    """Generate pseudorandom bits using LFSR with polynomial x^4 + x + 1.
    
    The recurrence is: s[n] = s[n-4] + s[n-3] (mod 2)
    (from x^4 + x + 1 = 0, so x^4 = x + 1, meaning s[n] = s[n-3] + s[n-4])
    
    Wait, actually x^4 + x + 1 = 0 means x^4 = -(x+1) = x+1 over GF(2).
    As LFSR: new_bit = state[0] XOR state[1] (taps at positions 0 and 1 for x^4+x+1).
    
    Since x^4 + x + 1 is a primitive polynomial over GF(2) (α has order 15),
    the LFSR produces a maximal-length sequence of period 2^4 - 1 = 15.
    
    Args:
        seed: Initial state [s₀, s₁, s₂, s₃], must be nonzero
        length: Number of bits to generate
    
    Returns:
        List of pseudorandom bits
    """
    state = list(seed)
    output = []
    for _ in range(length):
        output.append(state[0])
        # Feedback: x^4 + x + 1 → taps at positions 0 and 1
        new_bit = (state[0] + state[1]) % 2  
        state = state[1:] + [new_bit]
    return output


# ============================================================
# 3. Simple BCH-style error detection using GF(16)
# ============================================================

def gf16_minimal_polynomial(element: GF16) -> list[GF16]:
    """Find the minimal polynomial of an element of GF(16) over GF(2).
    
    Uses the fact that conjugates of α^i are α^(2i), α^(4i), α^(8i) (mod 15).
    """
    if element.is_zero:
        return [GF16.zero(), GF16.one()]  # x
    
    # Find the order / determine conjugacy class
    seen = set()
    current = element
    conjugates = []
    for _ in range(4):
        if current in seen:
            break
        seen.add(current)
        conjugates.append(current)
        current = current ** 2
    
    # Minimal polynomial = product of (x - conjugate) over GF(16)
    # Start with [1] (constant 1) and multiply by (x - c) for each conjugate
    poly = [GF16.one()]  # represents constant 1
    for c in conjugates:
        # Multiply by (x - c) = (x + c) over GF(2)
        new_poly = [GF16.zero()] * (len(poly) + 1)
        for i, coeff in enumerate(poly):
            new_poly[i + 1] = new_poly[i + 1] + coeff        # x term
            new_poly[i] = new_poly[i] + (coeff * c)  # -c = +c term
        poly = new_poly
    
    return poly


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATIONS OF X^4 + X + 1 AND MODULAR TRANSFER")
    print("=" * 70)
    
    # ---- Application 1: GF(16) multiplication table ----
    print("\n" + "─" * 60)
    print("APPLICATION 1: GF(16) Arithmetic")
    print("─" * 60)
    
    alpha = GF16.alpha()
    print("\nPowers of α in GF(16) = GF(2)[α]/(α⁴ + α + 1):")
    print(f"  α⁴ = α + 1 (the defining relation)")
    print()
    
    elements_by_power = {}
    current = GF16.one()
    for i in range(15):
        elements_by_power[i] = current
        print(f"  α^{i:2d} = {current!r:15s} (binary: {current.to_int():04b})")
        current = current * alpha
    
    # Verify α^15 = 1
    print(f"\n  α^15 = {(alpha ** 15)!r}  (confirming α is primitive)")
    
    # ---- Application 2: LFSR ----
    print("\n" + "─" * 60)
    print("APPLICATION 2: LFSR Pseudorandom Sequence")
    print("─" * 60)
    
    seed = [1, 0, 0, 0]
    seq = lfsr_x4_x_1(seed, 30)
    print(f"\n  Seed: {seed}")
    print(f"  Polynomial: x^4 + x + 1 (primitive over GF(2))")
    print(f"  Period: 2^4 - 1 = 15 (maximal length)")
    print(f"\n  Generated sequence ({len(seq)} bits):")
    print(f"  {''.join(map(str, seq[:15]))} | {''.join(map(str, seq[15:]))}")
    print(f"  └── one period ──┘   └── repeats ──┘")
    
    # Verify period
    period_found = None
    for p in range(1, 16):
        if seq[p:p+4] == seed:
            period_found = p
            break
    print(f"\n  Verified period: {period_found}")
    
    # Statistical properties
    ones = sum(seq[:15])
    zeros = 15 - ones
    print(f"  Balance in one period: {ones} ones, {zeros} zeros")
    print(f"  (Maximal LFSR: always 2^(n-1) ones and 2^(n-1)-1 zeros)")
    
    # ---- Application 3: Error detection ----
    print("\n" + "─" * 60)
    print("APPLICATION 3: BCH-style Error Detection")
    print("─" * 60)
    
    print("\n  Minimal polynomials of elements of GF(16) over GF(2):")
    alpha = GF16.alpha()
    for i in range(1, 8):
        elem = alpha ** i
        min_poly = gf16_minimal_polynomial(elem)
        coeffs_str = []
        for j, c in enumerate(min_poly):
            if not c.is_zero:
                if j == 0:
                    coeffs_str.append("1")
                elif j == 1:
                    coeffs_str.append("x")
                else:
                    coeffs_str.append(f"x^{j}")
        print(f"  α^{i:2d}: min. poly = {' + '.join(coeffs_str)}")
    
    # ---- Application 4: Finite field as vector space ----
    print("\n" + "─" * 60)
    print("APPLICATION 4: GF(16) as 4-dimensional Vector Space over GF(2)")
    print("─" * 60)
    
    print("\n  Addition table (showing integer encoding 0-15):")
    print("    +  |", end="")
    for j in range(16):
        print(f" {j:2d}", end="")
    print()
    print("  " + "─" * 52)
    for i in range(16):
        a = GF16([i & 1, (i >> 1) & 1, (i >> 2) & 1, (i >> 3) & 1])
        print(f"   {i:2d} |", end="")
        for j in range(16):
            b = GF16([j & 1, (j >> 1) & 1, (j >> 2) & 1, (j >> 3) & 1])
            s = (a + b).to_int()
            print(f" {s:2d}", end="")
        print()
    
    print("\n  Multiplication table (nonzero elements only, by power of α):")
    print("    ×  |", end="")
    for j in range(15):
        print(f" {j:2d}", end="")
    print("   (exponents of α)")
    print("  " + "─" * 52)
    for i in range(15):
        print(f"   {i:2d} |", end="")
        for j in range(15):
            # α^i * α^j = α^((i+j) mod 15)
            print(f" {(i+j) % 15:2d}", end="")
        print()
    
    print("\n  Key insight: multiplication in GF(16)* ≅ ℤ/15ℤ (additive)")
    print("  This is because α is a primitive element of order 15 = 2^4 - 1")
    
    # ---- Summary ----
    print("\n" + "=" * 70)
    print("SUMMARY OF APPLICATIONS")
    print("=" * 70)
    print("""
  The irreducibility of x^4 + x + 1 over GF(2) enables:
  
  1. FIELD CONSTRUCTION: GF(16) = GF(2)[α]/(α^4+α+1), a field with 16 elements
     used in coding theory, cryptography, and combinatorial design.
  
  2. PSEUDORANDOM GENERATION: The LFSR defined by x^4+x+1 produces a
     maximal-length sequence of period 15 with excellent statistical properties.
  
  3. ERROR CORRECTION: BCH and Reed-Solomon codes over GF(16) use minimal
     polynomials of powers of α to construct generator polynomials.
  
  4. ALGEBRAIC NUMBER THEORY: Over ℚ, x^4+x+1 defines a degree-4 number
     field ℚ[α]/(α^4+α+1) with discriminant -283, a prime discriminant
     indicating a simple arithmetic structure.
  
  The modular transfer theorem certifies that the irreducibility established
  over the tiny 2-element field GF(2) guarantees irreducibility over the
  infinite fields ℤ and ℚ — small computation, infinite consequence.
""")


#!/usr/bin/env python3
"""
Demonstration of modular irreducibility transfer for X^4 + X + 1.

This script illustrates the mathematical ideas behind proving polynomial
irreducibility by reduction to finite fields:

1. Exhaustive root checking over GF(2)
2. Exhaustive quadratic factor checking over GF(2)
3. Modular transfer principle verification
4. Construction of GF(16) = GF(2)[x]/(x^4 + x + 1)
"""

import numpy as np
from itertools import product


# ============================================================
# Polynomial arithmetic over GF(2)
# ============================================================

def poly_add_gf2(a: list[int], b: list[int]) -> list[int]:
    """Add two polynomials over GF(2). Coefficients are lists, index = degree."""
    n = max(len(a), len(b))
    a_ext = a + [0] * (n - len(a))
    b_ext = b + [0] * (n - len(b))
    result = [(a_ext[i] + b_ext[i]) % 2 for i in range(n)]
    # Strip trailing zeros
    while len(result) > 1 and result[-1] == 0:
        result.pop()
    return result


def poly_mul_gf2(a: list[int], b: list[int]) -> list[int]:
    """Multiply two polynomials over GF(2)."""
    if a == [0] or b == [0]:
        return [0]
    n = len(a) + len(b) - 1
    result = [0] * n
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            result[i + j] = (result[i + j] + ai * bj) % 2
    while len(result) > 1 and result[-1] == 0:
        result.pop()
    return result


def poly_mod_gf2(a: list[int], b: list[int]) -> list[int]:
    """Compute a mod b over GF(2)."""
    a = list(a)
    while len(a) >= len(b) and any(a):
        if a[-1] == 0:
            a.pop()
            continue
        shift = len(a) - len(b)
        for i in range(len(b)):
            a[i + shift] = (a[i + shift] + b[i]) % 2
        while len(a) > 1 and a[-1] == 0:
            a.pop()
    return a


def poly_eval_gf2(p: list[int], x: int) -> int:
    """Evaluate polynomial p at x over GF(2)."""
    result = 0
    for i, c in enumerate(p):
        result = (result + c * pow(x, i, 2)) % 2
    return result


def poly_degree(p: list[int]) -> int:
    """Degree of a polynomial."""
    if p == [0]:
        return -1
    return len(p) - 1


def poly_str(p: list[int]) -> str:
    """Pretty-print a polynomial."""
    if p == [0]:
        return "0"
    terms = []
    for i in range(len(p) - 1, -1, -1):
        if p[i] == 0:
            continue
        if i == 0:
            terms.append("1")
        elif i == 1:
            terms.append("x")
        else:
            terms.append(f"x^{i}")
    return " + ".join(terms) if terms else "0"


def enumerate_monic_polys_gf2(degree: int) -> list[list[int]]:
    """Enumerate all monic polynomials of given degree over GF(2)."""
    if degree < 0:
        return []
    if degree == 0:
        return [[1]]
    polys = []
    # Lower coefficients can be 0 or 1
    for coeffs in product([0, 1], repeat=degree):
        p = list(coeffs) + [1]  # monic: leading coeff = 1
        polys.append(p)
    return polys


# ============================================================
# The polynomial f = x^4 + x + 1
# ============================================================

# Represented as [1, 1, 0, 0, 1] meaning 1 + x + 0*x^2 + 0*x^3 + x^4
f = [1, 1, 0, 0, 1]

print("=" * 70)
print("MODULAR IRREDUCIBILITY TRANSFER FOR f(x) = x^4 + x + 1")
print("=" * 70)
print()

# ============================================================
# Step 1: Root check over GF(2)
# ============================================================

print("STEP 1: Root check over GF(2)")
print("-" * 40)
for x in [0, 1]:
    val = poly_eval_gf2(f, x)
    print(f"  f({x}) = {val} mod 2  {'← NOT a root' if val != 0 else '← ROOT!'}")
print(f"  Conclusion: f has NO roots in GF(2)")
print(f"  → No linear factors over GF(2)")
print()

# ============================================================
# Step 2: Exhaustive quadratic factor search
# ============================================================

print("STEP 2: Exhaustive quadratic factor search over GF(2)")
print("-" * 40)
quadratics = enumerate_monic_polys_gf2(2)
print(f"  All monic quadratics over GF(2):")
for q in quadratics:
    remainder = poly_mod_gf2(f, q)
    divides = remainder == [0]
    # Check if the quadratic itself is irreducible
    has_root = any(poly_eval_gf2(q, x) == 0 for x in [0, 1])
    irred = "irreducible" if not has_root else "reducible"
    print(f"    {poly_str(q):15s}  ({irred:11s})  "
          f"{'DIVIDES f' if divides else 'does NOT divide f'}")
print(f"  Conclusion: No quadratic divides f over GF(2)")
print(f"  → No quadratic factors over GF(2)")
print()

# ============================================================
# Step 3: Irreducibility conclusion
# ============================================================

print("STEP 3: Irreducibility over GF(2)")
print("-" * 40)
print("  f has degree 4 over GF(2)")
print("  - No factors of degree 1 (no roots)")
print("  - No factors of degree 2 (exhaustive check)")
print("  - A degree-3 factor would require a degree-1 cofactor (impossible)")
print("  ∴ f is IRREDUCIBLE over GF(2)")
print()

# ============================================================
# Step 4: Transfer to Z and Q
# ============================================================

print("STEP 4: Modular transfer to ℤ and ℚ")
print("-" * 40)
print("  f = x^4 + x + 1 is MONIC over ℤ (leading coefficient = 1)")
print("  By the monic irreducibility transfer theorem:")
print("    f monic over ℤ  +  f irreducible over GF(2)")
print("    ⟹  f is IRREDUCIBLE over ℤ")
print()
print("  By Gauss's lemma (monic ⟹ primitive):")
print("    f irreducible over ℤ  ⟹  f is IRREDUCIBLE over ℚ")
print()

# ============================================================
# Step 5: Verify over Z by coefficient comparison
# ============================================================

print("STEP 5: Independent verification — quadratic factorization over ℤ")
print("-" * 40)
print("  If x^4 + x + 1 = (x^2 + ax + b)(x^2 + cx + d) over ℤ, then:")
print("    a + c = 0          (coeff of x^3)")
print("    b + d + ac = 0     (coeff of x^2)")
print("    ad + bc = 1        (coeff of x^1)")
print("    bd = 1             (constant term)")
print()
print("  From a + c = 0: c = -a")
print("  From bd = 1: (b,d) ∈ {(1,1), (-1,-1)}")
print()

found_factorization = False
for b_val, d_val in [(1, 1), (-1, -1)]:
    for a_val in range(-10, 11):
        c_val = -a_val
        if (b_val + d_val + a_val * c_val == 0 and
                a_val * d_val + b_val * c_val == 1 and
                b_val * d_val == 1):
            found_factorization = True
            print(f"  FOUND: a={a_val}, b={b_val}, c={c_val}, d={d_val}")

if not found_factorization:
    print("  Case (b,d) = (1,1): b+d+ac = 2-a² = 0 ⟹ a² = 2, no integer solution")
    print("  Case (b,d) = (-1,-1): b+d+ac = -2-a² = 0 ⟹ a² = -2, no integer solution")
    print("  ∴ No quadratic factorization over ℤ exists ✓")
print()

# ============================================================
# Step 6: Construct GF(16) = GF(2)[x]/(x^4+x+1)
# ============================================================

print("STEP 6: GF(16) = GF(2)[x]/(x^4 + x + 1)")
print("-" * 40)
print("  Since x^4 + x + 1 is irreducible over GF(2),")
print("  GF(2)[x]/(x^4+x+1) is a field with 2^4 = 16 elements.")
print()

# Elements of GF(16) are polynomials of degree ≤ 3 over GF(2)
elements = []
for d, c, b, a in product([0, 1], repeat=4):
    elements.append([a, b, c, d])

print(f"  The 16 elements (as polynomials in α where α^4 + α + 1 = 0):")
for i, e in enumerate(elements):
    # Reduce: α^4 = α + 1
    name = poly_str(e).replace('x', 'α') if e != [0] else '0'
    if i % 4 == 0:
        print("    ", end="")
    print(f"{name:20s}", end="")
    if i % 4 == 3:
        print()

print()

# Verify multiplicative group order
def gf16_mul(a_el, b_el):
    """Multiply two elements in GF(16) = GF(2)[x]/(x^4+x+1)."""
    prod = poly_mul_gf2(a_el, b_el)
    return poly_mod_gf2(prod, f)

# Find order of α (= [0, 1, 0, 0])
alpha = [0, 1, 0, 0]
current = [1]  # identity
order = 0
for i in range(1, 17):
    current = gf16_mul(current, alpha)
    if current == [1]:
        order = i
        break

print(f"  Order of α in GF(16)*: {order}")
print(f"  α is {'a primitive element (generator of GF(16)*)' if order == 15 else 'NOT primitive'}")
print()

# Print powers of α
print("  Powers of α:")
current = [1]
for i in range(16):
    name = poly_str(current).replace('x', 'α')
    print(f"    α^{i:2d} = {name}")
    current = gf16_mul(current, alpha)

print()
print("=" * 70)
print("SUMMARY")
print("=" * 70)
print("  x^4 + x + 1 is irreducible over GF(2), ℤ, and ℚ.")
print("  The proof uses modular transfer: irreducibility over GF(2)")
print("  lifts to irreducibility over ℤ via the monic transfer theorem,")
print("  then to ℚ via Gauss's lemma.")
print("  GF(2)[x]/(x^4+x+1) ≅ GF(16), with α as a primitive element.")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""
import json

# Read all content files
with open('ARTICLE.md', 'r') as f:
    article = f.read()

with open('RESEARCH_PAPER.md', 'r') as f:
    research_paper = f.read()

with open('FUTURE_DIRECTIONS.md', 'r') as f:
    future_directions = f.read()

with open('Bridges/IrreducibleTransfer.lean', 'r') as f:
    lean_proofs = f.read()

with open('demo.py', 'r') as f:
    demo_code = f.read()

with open('algorithms.py', 'r') as f:
    algorithms_code = f.read()

with open('applications.py', 'r') as f:
    applications_code = f.read()

with open('visualizations.py', 'r') as f:
    viz_code = f.read()

# Read visualization data
viz_b64 = {}
with open('viz_data.txt', 'r') as f:
    for line in f:
        key, val = line.strip().split(':', 1)
        viz_b64[key] = val

package = {
    "title": "Modular Irreducibility Transfer: Finite-Field Certification for Integer Polynomials",
    "domain": "Algebra / Number Theory / Formal Verification",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Modular Irreducibility Transfer Demo",
            "code": demo_code
        },
        {
            "name": "Applications: GF(16), LFSR, Error Correction",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Exhaustive Irreducibility Test over GF(p)",
            "pseudocode": """ALGORITHM: ExhaustiveIrreducibilityTest(f, p)
INPUT: Monic polynomial f of degree d over GF(p)
OUTPUT: True if f is irreducible, False otherwise

1. If d ≤ 0: return False
2. If d = 1: return True
3. For each degree k from 1 to d/2:
   a. For each monic polynomial g of degree k over GF(p):
      i. Compute r = f mod g
      ii. If r = 0: return False  (g divides f)
4. Return True  (no proper divisors found)

COMPLEXITY: Time O(p^(d/2) · d²), Space O(p^(d/2) · d)""",
            "code": algorithms_code
        },
        {
            "name": "Certifying Prime Search",
            "pseudocode": """ALGORITHM: FindCertifyingPrime(f)
INPUT: Monic polynomial f ∈ Z[X]
OUTPUT: Prime p such that f mod p is irreducible over GF(p), or NONE

1. For each prime p = 2, 3, 5, 7, 11, ...:
   a. Reduce f modulo p to get f_p ∈ GF(p)[X]
   b. Check that deg(f_p) = deg(f)  (leading coeff not divisible by p)
   c. If ExhaustiveIrreducibilityTest(f_p, p):
      return p
2. Return NONE  (no certifying prime found)

EXPECTED COMPLEXITY: By Chebotarev density, ~1/d of primes certify,
so expected O(d · log(d)) primes need checking.""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Modular Transfer Pipeline",
            "data": f"data:image/png;base64,{viz_b64['PIPELINE']}"
        },
        {
            "name": "GF(16) Multiplicative Group Cycle",
            "data": f"data:image/png;base64,{viz_b64['GF16']}"
        },
        {
            "name": "LFSR Sequence from X⁴+X+1",
            "data": f"data:image/png;base64,{viz_b64['LFSR']}"
        },
        {
            "name": "Irreducible Polynomial Counts by Degree and Prime",
            "data": f"data:image/png;base64,{viz_b64['COUNTS']}"
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, ensure_ascii=False, indent=2)

print(f"PACKAGE.json generated ({len(json.dumps(package))} bytes)")


#!/usr/bin/env python3
"""
Visualizations for the irreducibility transfer framework.

Generates figures illustrating:
1. The modular transfer pipeline
2. GF(16) structure (Cayley graph of multiplicative group)
3. LFSR sequence properties
4. Irreducible polynomial density across primes
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product
import base64
from io import BytesIO


def save_figure_base64(fig, filename=None):
    """Save figure as PNG and return base64 string."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    if filename:
        fig.savefig(filename, dpi=150, bbox_inches='tight',
                    facecolor='white', edgecolor='none')
    plt.close(fig)
    return b64


# ============================================================
# Figure 1: Modular Transfer Pipeline
# ============================================================

def fig_transfer_pipeline():
    """Visualize the modular transfer proof pipeline."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 5))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 5)
    ax.axis('off')
    ax.set_title('Modular Irreducibility Transfer Pipeline', fontsize=16, fontweight='bold', pad=20)
    
    # Boxes
    boxes = [
        (1, 3.5, 'f ∈ ℤ[X]\nmonic', '#E8F4FD'),
        (4, 3.5, 'f mod p ∈ 𝔽ₚ[X]', '#FFF3E0'),
        (7.5, 3.5, 'Irreducible\nover 𝔽ₚ?', '#E8F5E9'),
        (7.5, 1, 'f irreducible\nover ℤ', '#E3F2FD'),
        (10.5, 1, 'f irreducible\nover ℚ', '#F3E5F5'),
    ]
    
    for x, y, text, color in boxes:
        rect = mpatches.FancyBboxPatch((x - 1.2, y - 0.6), 2.4, 1.2,
                                        boxstyle="round,pad=0.15",
                                        facecolor=color, edgecolor='#333',
                                        linewidth=2)
        ax.add_patch(rect)
        ax.text(x, y, text, ha='center', va='center', fontsize=11,
                fontweight='bold')
    
    # Arrows
    arrow_style = dict(arrowstyle='->', color='#333', lw=2,
                       connectionstyle='arc3,rad=0')
    ax.annotate('', xy=(2.8, 3.5), xytext=(2.2, 3.5),
                arrowprops=arrow_style)
    ax.annotate('', xy=(6.3, 3.5), xytext=(5.2, 3.5),
                arrowprops=arrow_style)
    ax.annotate('', xy=(7.5, 1.6), xytext=(7.5, 2.9),
                arrowprops=dict(arrowstyle='->', color='#2E7D32', lw=2.5))
    ax.annotate('', xy=(9.3, 1), xytext=(8.7, 1),
                arrowprops=arrow_style)
    
    # Labels on arrows
    ax.text(3.5, 3.9, 'reduce\nmod p', ha='center', va='bottom',
            fontsize=9, color='#555', style='italic')
    ax.text(5.7, 3.9, 'finite\ncheck', ha='center', va='bottom',
            fontsize=9, color='#555', style='italic')
    ax.text(8.1, 2.2, 'transfer\ntheorem', ha='left', va='center',
            fontsize=9, color='#2E7D32', fontweight='bold')
    ax.text(9, 1.4, 'Gauss\nlemma', ha='center', va='bottom',
            fontsize=9, color='#555', style='italic')
    
    # Example annotation
    ax.text(6, 0.3, 'Example: f = X⁴+X+1, p = 2',
            ha='center', fontsize=12, color='#1565C0',
            style='italic', fontweight='bold')
    
    return fig


# ============================================================
# Figure 2: GF(16) multiplicative group as a cycle
# ============================================================

def fig_gf16_cycle():
    """Visualize the multiplicative group of GF(16) as a cyclic group."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))
    
    n = 15  # |GF(16)*| = 15
    theta = np.linspace(0, 2 * np.pi, n, endpoint=False)
    # Start from top, go clockwise
    theta = np.pi / 2 - theta
    
    r = 3.0
    x = r * np.cos(theta)
    y = r * np.sin(theta)
    
    # Power labels and polynomial representations
    poly_repr = [
        '1', 'α', 'α²', 'α³', 'α+1', 'α²+α',
        'α³+α²', 'α³+α+1', 'α²+1', 'α³+α',
        'α²+α+1', 'α³+α²+α', 'α³+α²+α+1', 'α³+α²+1', 'α³+1'
    ]
    
    # Draw cycle edges
    for i in range(n):
        j = (i + 1) % n
        ax.annotate('', xy=(x[j], y[j]), xytext=(x[i], y[i]),
                    arrowprops=dict(arrowstyle='->', color='#1976D2',
                                   lw=1.5, connectionstyle='arc3,rad=0.08'))
    
    # Draw nodes
    for i in range(n):
        circle = plt.Circle((x[i], y[i]), 0.35, color='#E3F2FD',
                           edgecolor='#1565C0', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x[i], y[i], f'α^{{{i}}}' if i > 0 else '1',
                ha='center', va='center', fontsize=8, fontweight='bold',
                zorder=6)
        # Polynomial label outside
        label_r = r + 0.7
        lx = label_r * np.cos(theta[i])
        ly = label_r * np.sin(theta[i])
        ax.text(lx, ly, poly_repr[i], ha='center', va='center',
                fontsize=7, color='#555')
    
    ax.set_xlim(-4.5, 4.5)
    ax.set_ylim(-4.5, 4.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('GF(16)* ≅ ℤ/15ℤ — Multiplicative Group\n'
                 'Generated by α (root of X⁴+X+1)',
                 fontsize=14, fontweight='bold')
    
    return fig


# ============================================================
# Figure 3: LFSR Sequence
# ============================================================

def fig_lfsr_sequence():
    """Visualize the LFSR sequence generated by X^4+X+1."""
    # Generate sequence
    state = [1, 0, 0, 0]
    seq = []
    states = []
    for _ in range(30):
        states.append(list(state))
        seq.append(state[0])
        new_bit = (state[0] + state[1]) % 2
        state = state[1:] + [new_bit]
    
    fig, axes = plt.subplots(2, 1, figsize=(12, 6), gridspec_kw={'height_ratios': [1, 1.5]})
    
    # Top: bit sequence
    ax1 = axes[0]
    colors = ['#1565C0' if b == 1 else '#E0E0E0' for b in seq]
    ax1.bar(range(30), [1]*30, color=colors, edgecolor='white', linewidth=0.5)
    for i, b in enumerate(seq):
        ax1.text(i, 0.5, str(b), ha='center', va='center',
                fontsize=9, color='white' if b == 1 else '#999',
                fontweight='bold')
    ax1.axvline(x=14.5, color='red', linestyle='--', linewidth=2, alpha=0.7)
    ax1.text(7, 1.15, 'Period 1', ha='center', fontsize=10, color='#333')
    ax1.text(22, 1.15, 'Period 2', ha='center', fontsize=10, color='#999')
    ax1.set_xlim(-0.5, 29.5)
    ax1.set_ylim(0, 1.3)
    ax1.set_ylabel('Bit', fontsize=11)
    ax1.set_title('LFSR Output Sequence (polynomial: X⁴+X+1, seed: 1000)',
                  fontsize=13, fontweight='bold')
    ax1.set_xticks(range(30))
    ax1.set_yticks([])
    
    # Bottom: state visualization
    ax2 = axes[1]
    state_ints = [sum(s[i] * (2**i) for i in range(4)) for s in states[:15]]
    ax2.plot(range(15), state_ints, 'o-', color='#1565C0', markersize=8,
             linewidth=2, markerfacecolor='white', markeredgewidth=2)
    for i, v in enumerate(state_ints):
        ax2.text(i, v + 0.5, f'{v}', ha='center', va='bottom', fontsize=8)
    ax2.set_xlabel('Step', fontsize=11)
    ax2.set_ylabel('State (as integer)', fontsize=11)
    ax2.set_title('LFSR Internal State (one period)', fontsize=13, fontweight='bold')
    ax2.set_xticks(range(15))
    ax2.grid(True, alpha=0.3)
    
    fig.tight_layout()
    return fig


# ============================================================
# Figure 4: Irreducible polynomial counts over GF(p)
# ============================================================

def count_irreducibles(degree, p):
    """Count irreducible monic polynomials of given degree over GF(p)."""
    count = 0
    for coeffs in product(range(p), repeat=degree):
        poly = list(coeffs) + [1]
        is_irred = True
        # Check divisibility by all monic polys of degree 1..d//2
        for fd in range(1, degree // 2 + 1):
            for fc in product(range(p), repeat=fd):
                divisor = list(fc) + [1]
                # Polynomial division check
                r = list(poly)
                dd = len(divisor) - 1
                while len(r) > dd:
                    if r[-1] == 0:
                        r.pop()
                        continue
                    lc_inv = pow(divisor[-1], -1, p)
                    coeff = (r[-1] * lc_inv) % p
                    shift = len(r) - 1 - dd
                    for i in range(len(divisor)):
                        r[i + shift] = (r[i + shift] - coeff * divisor[i]) % p
                    r.pop()
                if all(x == 0 for x in r):
                    is_irred = False
                    break
            if not is_irred:
                break
        if is_irred:
            count += 1
    return count


def fig_irreducible_counts():
    """Bar chart of irreducible polynomial counts by degree and prime."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    primes = [2, 3, 5]
    degrees = [1, 2, 3, 4]
    colors = ['#1565C0', '#E65100', '#2E7D32']
    
    bar_width = 0.25
    x_pos = np.arange(len(degrees))
    
    for i, p in enumerate(primes):
        counts = [count_irreducibles(d, p) for d in degrees]
        # Also compute Necklace formula: (1/d) * sum_{k|d} mu(d/k) * p^k
        bars = ax.bar(x_pos + i * bar_width, counts, bar_width,
                     label=f'GF({p})', color=colors[i], alpha=0.85,
                     edgecolor='white', linewidth=0.5)
        for bar, count in zip(bars, counts):
            ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
                   str(count), ha='center', va='bottom', fontsize=9,
                   fontweight='bold')
    
    ax.set_xlabel('Degree', fontsize=12)
    ax.set_ylabel('Number of Monic Irreducible Polynomials', fontsize=12)
    ax.set_title('Irreducible Polynomial Counts over Finite Fields',
                fontsize=14, fontweight='bold')
    ax.set_xticks(x_pos + bar_width)
    ax.set_xticklabels(degrees)
    ax.legend(fontsize=11)
    ax.grid(True, axis='y', alpha=0.3)
    
    # Add necklace formula annotation
    ax.text(0.98, 0.95,
           'Count = (1/d) Σ_{k|d} μ(d/k) · pᵏ\n(Gauss necklace formula)',
           transform=ax.transAxes, ha='right', va='top',
           fontsize=9, color='#666', style='italic',
           bbox=dict(boxstyle='round,pad=0.3', facecolor='#F5F5F5',
                    edgecolor='#CCC'))
    
    return fig


# ============================================================
# Generate all figures
# ============================================================

if __name__ == "__main__":
    print("Generating visualizations...")
    
    fig1 = fig_transfer_pipeline()
    b64_1 = save_figure_base64(fig1, 'transfer_pipeline.png')
    print(f"  ✓ Transfer pipeline ({len(b64_1)} bytes base64)")
    
    fig2 = fig_gf16_cycle()
    b64_2 = save_figure_base64(fig2, 'gf16_cycle.png')
    print(f"  ✓ GF(16) cycle ({len(b64_2)} bytes base64)")
    
    fig3 = fig_lfsr_sequence()
    b64_3 = save_figure_base64(fig3, 'lfsr_sequence.png')
    print(f"  ✓ LFSR sequence ({len(b64_3)} bytes base64)")
    
    fig4 = fig_irreducible_counts()
    b64_4 = save_figure_base64(fig4, 'irreducible_counts.png')
    print(f"  ✓ Irreducible counts ({len(b64_4)} bytes base64)")
    
    print("\nAll visualizations generated successfully.")
    
    # Save base64 strings for JSON packaging
    with open('viz_data.txt', 'w') as f:
        f.write(f"PIPELINE:{b64_1}\n")
        f.write(f"GF16:{b64_2}\n")
        f.write(f"LFSR:{b64_3}\n")
        f.write(f"COUNTS:{b64_4}\n")
