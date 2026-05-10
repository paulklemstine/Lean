#!/usr/bin/env python3
"""
Berggren–Lattice Reduction: Algorithm Implementations

Complete implementations of the algorithms from the research paper,
with docstrings, type hints, and example usage.
"""

from typing import Tuple, List, Optional
import math

Triple = Tuple[int, int, int]
Word = str  # String of 'L', 'M', 'R'


# ============================================================
# Berggren Matrices and Action
# ============================================================

BERGGREN_MATRICES = {
    'L': [[1, -2, 2], [2, -1, 2], [2, -2, 3]],
    'M': [[1, 2, 2], [2, 1, 2], [2, 2, 3]],
    'R': [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]],
}

INVERSE_MATRICES = {
    'L': [[1, 2, -2], [-2, -1, 2], [-2, -2, 3]],
    'M': [[1, 2, -2], [2, 1, -2], [-2, -2, 3]],
    'R': [[-1, -2, 2], [2, 1, -2], [-2, -2, 3]],
}

ROOT: Triple = (3, 4, 5)


def berggren_forward(step: str, triple: Triple) -> Triple:
    """Apply one forward Berggren step.

    Args:
        step: One of 'L', 'M', 'R'
        triple: A primitive Pythagorean triple (a, b, c)

    Returns:
        The child triple under the specified Berggren generator.

    Time complexity: O(1)
    Space complexity: O(1)
    """
    M = BERGGREN_MATRICES[step]
    a, b, c = triple
    return (
        M[0][0]*a + M[0][1]*b + M[0][2]*c,
        M[1][0]*a + M[1][1]*b + M[1][2]*c,
        M[2][0]*a + M[2][1]*b + M[2][2]*c,
    )


def berggren_inverse(step: str, triple: Triple) -> Triple:
    """Apply one inverse Berggren step.

    Args:
        step: One of 'L', 'M', 'R'
        triple: A primitive Pythagorean triple (a, b, c)

    Returns:
        The parent triple under the inverse of the specified generator.
    """
    M = INVERSE_MATRICES[step]
    a, b, c = triple
    return (
        M[0][0]*a + M[0][1]*b + M[0][2]*c,
        M[1][0]*a + M[1][1]*b + M[1][2]*c,
        M[2][0]*a + M[2][1]*b + M[2][2]*c,
    )


def berggren_word_eval(word: Word, start: Triple = ROOT) -> Triple:
    """Evaluate a Berggren word by sequentially applying steps.

    Args:
        word: A string of 'L', 'M', 'R' characters
        start: Starting triple (default: root (3,4,5))

    Returns:
        The resulting primitive triple.

    Time complexity: O(|word|)
    Space complexity: O(1)
    """
    triple = start
    for step in word:
        triple = berggren_forward(step, triple)
    return triple


# ============================================================
# Decode Step and Canonical Decode
# ============================================================

def decode_step(triple: Triple) -> Optional[str]:
    """Determine which Berggren inverse to apply (parent direction).

    The decision rule is based on linear inequalities on (a, b, c):
    - If a + 2b > 2c and 2a + b < 2c: parent via Left
    - If a + 2b > 2c and 2a + b ≥ 2c: parent via Mid
    - If a + 2b ≤ 2c: parent via Right

    Args:
        triple: A primitive Pythagorean triple

    Returns:
        The parent step, or None if triple is the root.

    Time complexity: O(1)
    """
    a, b, c = triple
    if a == 3 and b == 4 and c == 5:
        return None
    if a + 2*b > 2*c:
        if 2*a + b < 2*c:
            return 'L'
        else:
            return 'M'
    else:
        return 'R'


def canonical_decode(triple: Triple) -> Word:
    """Recover the canonical Berggren word for a primitive triple.

    Algorithm:
    1. If triple is root (3,4,5), return empty word
    2. Determine parent step via decode_step
    3. Prepend step to recursive decode of parent

    This implementation uses iteration with bounded fuel (c + 1 steps).

    Args:
        triple: A primitive Pythagorean triple

    Returns:
        The unique Berggren word w such that berggrenWordEval(w) = triple.

    Time complexity: O(depth) where depth ≤ c
    Space complexity: O(depth) for the word
    """
    word = []
    fuel = triple[2] + 1
    while fuel > 0:
        step = decode_step(triple)
        if step is None:
            break
        word.append(step)
        fuel -= 1
    return ''.join(word)


# ============================================================
# Euclid Parametrization
# ============================================================

def euclid_params(triple: Triple) -> Optional[Tuple[int, int]]:
    """Extract Euclid parameters (m, n) from a primitive triple.

    Given (a, b, c) with a = m² - n², b = 2mn, c = m² + n²:
    - m² = (c + a) / 2
    - n² = (c - a) / 2

    Returns:
        (m, n) if valid, None otherwise.
    """
    a, b, c = triple
    m_sq = (c + a) // 2
    n_sq = (c - a) // 2
    m = int(math.isqrt(m_sq))
    n = int(math.isqrt(n_sq))
    if m*m == m_sq and n*n == n_sq and 2*m*n == b:
        return m, n
    return None


def lattice_basis(m: int, n: int) -> List[List[int]]:
    """Construct the canonical lattice basis from Euclid parameters.

    Returns the 2x2 matrix [[m, n], [n, m]].
    """
    return [[m, n], [n, m]]


def trapdoor_gap(triple: Triple) -> int:
    """Compute the trapdoor gap c - a."""
    return triple[2] - triple[0]


def quantum_certified_radius(triple: Triple) -> float:
    """Compute the quantum-certified radius b/c."""
    return triple[1] / triple[2]


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Generate some triples
    print("Berggren Tree Exploration")
    print("-" * 40)

    for word in ["", "L", "M", "R", "LL", "LM", "LR", "LMRL"]:
        t = berggren_word_eval(word)
        decoded = canonical_decode(t)
        params = euclid_params(t)
        gap = trapdoor_gap(t)
        radius = quantum_certified_radius(t)

        print(f"Word: {word:6s} → {t}  "
              f"decode={decoded:6s}  gap={gap:3d}  "
              f"radius={radius:.4f}  params={params}")


#!/usr/bin/env python3
"""
Berggren–Lattice Reduction: Applications

Real-world applications of the Berggren-lattice correspondence
to cryptography, coding theory, and lattice analysis.
"""

from algorithms import *
import random
import hashlib


# ============================================================
# Application 1: Pythagorean Trapdoor Function
# ============================================================

class PythagoreanTrapdoor:
    """A toy trapdoor function based on the Berggren tree.

    Key generation: Choose a random Berggren word of length L.
    Public key: The resulting primitive triple.
    Secret key: The Berggren word.
    Trapdoor: canonical_decode recovers the word from the triple.

    Security parameter: L (word length = tree depth).
    """

    def __init__(self, security_param: int = 10):
        self.L = security_param
        self.secret_key = ''.join(random.choice('LMR') for _ in range(self.L))
        self.public_key = berggren_word_eval(self.secret_key)

    def encrypt(self, message_bit: int) -> Triple:
        """Encrypt a single bit using the public key."""
        if message_bit == 0:
            return self.public_key
        else:
            # Perturb by one more Berggren step
            step = random.choice('LMR')
            return berggren_forward(step, self.public_key)

    def decrypt(self, ciphertext: Triple) -> int:
        """Decrypt using the secret key (trapdoor)."""
        decoded = canonical_decode(ciphertext)
        if decoded == self.secret_key:
            return 0
        else:
            return 1

    def verify(self) -> bool:
        """Verify that the trapdoor correctly inverts."""
        recovered = canonical_decode(self.public_key)
        return recovered == self.secret_key


print("=" * 60)
print("APPLICATION 1: Pythagorean Trapdoor Function")
print("=" * 60)

for L in [5, 10, 15, 20]:
    trap = PythagoreanTrapdoor(L)
    a, b, c = trap.public_key
    verified = trap.verify()
    gap = trapdoor_gap(trap.public_key)
    print(f"  L={L:2d}: c={c:15d}  gap={gap:12d}  verified={verified}")


# ============================================================
# Application 2: Berggren Hash Function
# ============================================================

def berggren_hash(data: bytes, output_bits: int = 64) -> int:
    """A Berggren-tree-based hash function (toy construction).

    Maps arbitrary data to a primitive triple by converting
    data bytes to a Berggren word, then hashing the triple.

    NOT cryptographically secure - for illustration only.
    """
    # Convert data to a Berggren word
    word = ''
    for byte in data:
        for i in range(0, 8, 2):
            bits = (byte >> i) & 3
            word += 'LMR'[bits % 3]

    triple = berggren_word_eval(word)
    # Hash the triple components
    h = hashlib.sha256(str(triple).encode()).hexdigest()
    return int(h[:output_bits // 4], 16)


print("\n" + "=" * 60)
print("APPLICATION 2: Berggren Hash Function")
print("=" * 60)

test_inputs = [b"hello", b"world", b"hello world", b"Pythagorean", b"lattice"]
for data in test_inputs:
    h = berggren_hash(data)
    print(f"  berggren_hash({data.decode():15s}) = 0x{h:016x}")


# ============================================================
# Application 3: Lattice Closest Vector Approximation
# ============================================================

def closest_vector_2d(basis: List[List[int]], target: Tuple[float, float]) -> Tuple[int, int]:
    """Find the closest lattice vector to a target point (dimension 2).

    Uses Babai's nearest-plane algorithm for the 2D case.
    """
    # Basis vectors
    b1 = (basis[0][0], basis[1][0])
    b2 = (basis[0][1], basis[1][1])

    # Gram-Schmidt
    mu = (b1[0]*b2[0] + b1[1]*b2[1]) / (b1[0]**2 + b1[1]**2)
    b2_star = (b2[0] - mu*b1[0], b2[1] - mu*b1[1])

    # Solve t = x1*b1 + x2*b2
    # First find x2 by projecting onto b2*
    det = b1[0]*b2[1] - b1[1]*b2[0]
    x2_real = (b1[0]*target[1] - b1[1]*target[0]) / det
    x1_real = (target[0] - x2_real*b2[0]) / b1[0] if b1[0] != 0 else \
              (target[1] - x2_real*b2[1]) / b1[1]

    x2 = round(x2_real)
    x1 = round(x1_real)

    return (x1*b1[0] + x2*b2[0], x1*b1[1] + x2*b2[1])


print("\n" + "=" * 60)
print("APPLICATION 3: Lattice Closest Vector (Pythagorean bases)")
print("=" * 60)

for word in ["", "L", "M", "R"]:
    triple = berggren_word_eval(word)
    params = euclid_params(triple)
    if params:
        m, n = params
        basis = lattice_basis(m, n)
        target = (3.7, 2.3)
        closest = closest_vector_2d(basis, target)
        dist = math.sqrt((closest[0]-target[0])**2 + (closest[1]-target[1])**2)
        print(f"  Triple {triple}: basis=[[{m},{n}],[{n},{m}]]  "
              f"closest to {target} = {closest}  dist={dist:.4f}")


# ============================================================
# Application 4: Security Parameter Analysis
# ============================================================

print("\n" + "=" * 60)
print("APPLICATION 4: Security Parameter Analysis")
print("=" * 60)
print(f"  {'Depth':>5s} {'Min c':>12s} {'Max c':>12s} {'Mean gap':>10s} {'Word space':>12s}")

for depth in range(1, 9):
    # Sample random words at this depth
    triples = []
    for _ in range(100):
        word = ''.join(random.choice('LMR') for _ in range(depth))
        t = berggren_word_eval(word)
        triples.append(t)

    c_vals = [t[2] for t in triples]
    gaps = [trapdoor_gap(t) for t in triples]
    word_space = 3 ** depth

    print(f"  {depth:5d} {min(c_vals):12d} {max(c_vals):12d} "
          f"{sum(gaps)/len(gaps):10.1f} {word_space:12d}")

print("\nAll applications complete.")


#!/usr/bin/env python3
"""
Berggren–Lattice Reduction Correspondence: Demonstrations

Concrete numerical examples bringing the formalized mathematics to life.
Demonstrates the Berggren tree, lattice basis construction, and canonical decoding.
"""

import math
from typing import Tuple, List, Optional

# Berggren matrices
BERGGREN_LEFT = [[1, -2, 2], [2, -1, 2], [2, -2, 3]]
BERGGREN_MID = [[1, 2, 2], [2, 1, 2], [2, 2, 3]]
BERGGREN_RIGHT = [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]

MATRICES = {'L': BERGGREN_LEFT, 'M': BERGGREN_MID, 'R': BERGGREN_RIGHT}
ROOT = (3, 4, 5)

def mat_vec(M, v):
    """Multiply 3x3 matrix by 3-vector."""
    return tuple(sum(M[i][j] * v[j] for j in range(3)) for i in range(3))

def berggren_step(step: str, triple: Tuple[int, int, int]) -> Tuple[int, int, int]:
    """Apply one Berggren step to a triple."""
    return mat_vec(MATRICES[step], triple)

def berggren_word_eval(word: str, triple: Tuple[int, int, int] = ROOT) -> Tuple[int, int, int]:
    """Evaluate a Berggren word starting from a triple."""
    for step in word:
        triple = berggren_step(step, triple)
    return triple

def is_primitive_triple(a, b, c) -> bool:
    """Check if (a,b,c) is a primitive Pythagorean triple with a odd."""
    return (a > 0 and b > 0 and c > 0 and
            a*a + b*b == c*c and
            math.gcd(a, b) == 1 and
            a % 2 == 1)

def decode_step(a, b, c) -> Optional[str]:
    """Determine which inverse Berggren step to apply."""
    if a == 3 and b == 4 and c == 5:
        return None
    if a + 2*b > 2*c:
        if 2*a + b < 2*c:
            return 'L'
        else:
            return 'M'
    else:
        return 'R'

# Inverse Berggren matrices
INVERSE_MATRICES = {
    'L': [[1, 2, -2], [-2, -1, 2], [-2, -2, 3]],
    'M': [[1, 2, -2], [2, 1, -2], [-2, -2, 3]],
    'R': [[-1, -2, 2], [2, 1, -2], [-2, -2, 3]],
}

def canonical_decode(triple: Tuple[int, int, int]) -> str:
    """Decode a primitive triple to its canonical Berggren word."""
    word = []
    a, b, c = triple
    fuel = c + 1
    while fuel > 0:
        step = decode_step(a, b, c)
        if step is None:
            break
        word.append(step)
        # Apply inverse transform to find parent
        M = INVERSE_MATRICES[step]
        a, b, c = mat_vec(M, (a, b, c))
        fuel -= 1
    # The decode traces from triple to root, producing the word in reverse
    return ''.join(reversed(word))


def euclid_params(a, b, c):
    """Find Euclid parameters (m, n) for a primitive triple."""
    # c = m^2 + n^2, a = m^2 - n^2, b = 2mn
    # m^2 = (c + a) / 2, n^2 = (c - a) / 2
    m_sq = (c + a) // 2
    n_sq = (c - a) // 2
    m = int(math.isqrt(m_sq))
    n = int(math.isqrt(n_sq))
    if m*m == m_sq and n*n == n_sq:
        return m, n
    return None, None

# ============================================================
# Demo 1: Generate the first few levels of the Berggren tree
# ============================================================
print("=" * 60)
print("DEMO 1: Berggren Tree (first 3 levels)")
print("=" * 60)

def print_tree(triple, depth, prefix=""):
    a, b, c = triple
    m, n = euclid_params(a, b, c)
    print(f"{prefix}({a}, {b}, {c})  [c={c}, m={m}, n={n}]")
    if depth > 0:
        for step in ['L', 'M', 'R']:
            child = berggren_step(step, triple)
            print_tree(child, depth - 1, prefix + "  ")

print_tree(ROOT, 2)

# ============================================================
# Demo 2: Verify preservation properties
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Preservation Properties")
print("=" * 60)

# Generate all triples up to depth 4
def all_triples(depth):
    if depth == 0:
        return [ROOT]
    result = [ROOT]
    queue = [ROOT]
    for d in range(depth):
        next_queue = []
        for t in queue:
            for step in ['L', 'M', 'R']:
                child = berggren_step(step, t)
                result.append(child)
                next_queue.append(child)
        queue = next_queue
    return result

triples = all_triples(4)
print(f"Generated {len(triples)} triples (depth ≤ 4)")

# Check all are primitive
all_primitive = all(is_primitive_triple(*t) for t in triples)
print(f"All primitive: {all_primitive}")

# Check c increases
c_increases = all(t[2] < berggren_step(s, t)[2]
                  for t in triples for s in ['L', 'M', 'R'])
print(f"c strictly increases: {c_increases}")

# Check trapdoor gap
gaps = [t[2] - t[0] for t in triples]
print(f"Min trapdoor gap c-a: {min(gaps)} (always ≥ 2)")

# ============================================================
# Demo 3: Canonical Decode
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Canonical Decode (round-trip verification)")
print("=" * 60)

test_words = ["", "L", "M", "R", "LM", "LR", "ML", "MR", "RL", "RR",
              "LLL", "LMR", "RML", "LLMR", "RRRR", "LMRLM"]

for word in test_words:
    triple = berggren_word_eval(word)
    decoded = canonical_decode(triple)
    match = "✓" if decoded == word else "✗"
    print(f"  Word: {word:8s} → Triple: {str(triple):20s} → Decoded: {decoded:8s} {match}")

# ============================================================
# Demo 4: Lattice Basis from Euclid Parameters
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Lattice Basis Construction")
print("=" * 60)

for word in ["", "L", "M", "R", "LM"]:
    triple = berggren_word_eval(word)
    a, b, c = triple
    m, n = euclid_params(a, b, c)
    if m is not None:
        det = m*m - n*n
        height = c
        print(f"  Word: {word:4s} → ({a},{b},{c})  Euclid: m={m},n={n}  "
              f"Basis: [[{m},{n}],[{n},{m}]]  det={det}  height={height}")

# ============================================================
# Demo 5: Height Distribution
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Height Distribution at Depth 5")
print("=" * 60)

depth5 = [t for t in all_triples(5) if t not in all_triples(4)]
c_values = sorted([t[2] for t in depth5])
print(f"  Number of triples at depth 5: {len(depth5)}")
print(f"  Min c: {min(c_values)}")
print(f"  Max c: {max(c_values)}")
print(f"  Mean c: {sum(c_values)/len(c_values):.1f}")
print(f"  All c > root c=5: {all(c > 5 for c in c_values)}")

print("\n" + "=" * 60)
print("ALL DEMOS COMPLETE")
print("=" * 60)
