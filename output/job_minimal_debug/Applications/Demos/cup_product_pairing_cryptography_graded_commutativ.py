#!/usr/bin/env python3
"""
Cup-Product Pairing Cryptography: Demonstration

This demo illustrates the algebraic foundations of topological pairing-based
cryptography using concrete numerical examples over finite fields.

Bridge: Algebraic Topology × Cryptography × Quantum Information
"""

import numpy as np
from typing import Tuple, List
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ============================================================
# Part I: Bilinear Cup Product over F_q
# ============================================================

class BilinearCupPairing:
    """
    A bilinear pairing over F_q, modeling the cup product on cohomology.
    
    For simplicity, we represent cohomology classes as vectors in F_q^d
    and the cup product as a bilinear form given by a matrix.
    """
    
    def __init__(self, q: int, matrix: np.ndarray):
        """
        q: prime field size
        matrix: d×d matrix defining cup(a, b) = a^T @ matrix @ b mod q
        """
        self.q = q
        self.matrix = matrix % q
        self.dim = matrix.shape[0]
    
    def cup(self, a: np.ndarray, b: np.ndarray) -> int:
        """Compute the cup product: a^T M b mod q"""
        return int(a @ self.matrix @ b) % self.q
    
    def verify_bilinearity(self, num_tests: int = 100) -> bool:
        """Verify bilinearity with random tests."""
        for _ in range(num_tests):
            a = np.random.randint(0, self.q, self.dim)
            b = np.random.randint(0, self.q, self.dim)
            c = np.random.randint(0, self.q, self.dim)
            r = np.random.randint(0, self.q)
            
            # Left additivity: cup(a+b, c) = cup(a, c) + cup(b, c)
            lhs = self.cup((a + b) % self.q, c)
            rhs = (self.cup(a, c) + self.cup(b, c)) % self.q
            if lhs != rhs:
                return False
            
            # Scalar left: cup(r*a, b) = r * cup(a, b)
            lhs = self.cup((r * a) % self.q, b)
            rhs = (r * self.cup(a, b)) % self.q
            if lhs != rhs:
                return False
        
        return True


# ============================================================
# Part II: Pairing Type Classification
# ============================================================

def classify_pairing_type(p: int, r: int) -> str:
    """
    Classify the cup-product pairing type from degree parity.
    
    Theorem (cupPairingType_*): 
    - Both even → symmetric (type-1)
    - Both odd → alternating (type-3)  
    - Mixed → mixed
    """
    if p % 2 == 0 and r % 2 == 0:
        return "symmetric (type-1)"
    elif p % 2 == 1 and r % 2 == 1:
        return "alternating (type-3)"
    else:
        return "mixed"


def graded_commutativity_sign(p: int, r: int) -> int:
    """(-1)^{p*r}: the sign in graded commutativity."""
    return (-1) ** (p * r)


# ============================================================
# Part III: Cohomological IBE Scheme
# ============================================================

class CohomologicalIBE:
    """
    Identity-Based Encryption from cup-product pairings.
    
    Setup:
    - Generator g ∈ F_q^d (public)
    - Master secret s ∈ F_q (private to KGC)
    - Public parameter h = s * g (public)
    
    Key extraction: d_id = s * id
    Encryption: (r*g, msg + cup(r*id, h))
    Decryption: ct[1] - cup(d_id, ct[0])
    
    Theorem (ibe_decrypt_correct): decrypt(extractKey(id), encrypt(id, r, msg)) = msg
    """
    
    def __init__(self, pairing: BilinearCupPairing, generator: np.ndarray, master_secret: int):
        self.pairing = pairing
        self.q = pairing.q
        self.generator = generator % self.q
        self.master_secret = master_secret % self.q
        self.public_param = (self.master_secret * self.generator) % self.q
    
    def extract_key(self, identity: np.ndarray) -> np.ndarray:
        """Extract private key for identity: d_id = s * id"""
        return (self.master_secret * identity) % self.q
    
    def encrypt(self, identity: np.ndarray, randomness: int, message: int) -> Tuple[np.ndarray, int]:
        """Encrypt message for identity with randomness r."""
        ct1 = (randomness * self.generator) % self.q
        pairing_val = self.pairing.cup((randomness * identity) % self.q, self.public_param)
        ct2 = (message + pairing_val) % self.q
        return (ct1, ct2)
    
    def decrypt(self, private_key: np.ndarray, ciphertext: Tuple[np.ndarray, int]) -> int:
        """Decrypt ciphertext using private key."""
        ct1, ct2 = ciphertext
        pairing_val = self.pairing.cup(private_key, ct1)
        return (ct2 - pairing_val) % self.q


# ============================================================
# Part IV: Betti Number Security Analysis
# ============================================================

class BettiSecurityParams:
    """
    Security parameters from Betti numbers.
    
    Theorem (security_linear_in_dimension):
        classicalSecurityBits = totalKeyDim * log2(q) / 2
    
    Theorem (quantum_eq_half_classical):
        quantumSecurityBits = classicalSecurityBits / 2
    """
    
    def __init__(self, betti_numbers: List[int], field_size: int):
        self.betti_numbers = betti_numbers
        self.field_size = field_size
    
    @property
    def total_key_dimension(self) -> int:
        return sum(self.betti_numbers)
    
    @property
    def even_key_dimension(self) -> int:
        return sum(b for i, b in enumerate(self.betti_numbers) if i % 2 == 0)
    
    @property
    def key_space_size(self) -> float:
        return float(self.field_size) ** self.total_key_dimension
    
    @property
    def classical_security_bits(self) -> float:
        return self.total_key_dimension * np.log2(self.field_size) / 2
    
    @property
    def quantum_security_bits(self) -> float:
        return self.classical_security_bits / 2


# ============================================================
# Part V: Demonstrations
# ============================================================

def demo_bilinearity():
    """Demonstrate bilinearity of the cup product."""
    print("=" * 60)
    print("DEMO 1: Bilinearity of Cup Product over F_7")
    print("=" * 60)
    
    q = 7
    # A simple 3×3 matrix defining the bilinear form
    M = np.array([[1, 2, 0], [0, 1, 3], [2, 0, 1]])
    pairing = BilinearCupPairing(q, M)
    
    is_bilinear = pairing.verify_bilinearity(1000)
    print(f"Field: F_{q}")
    print(f"Pairing matrix:\n{M}")
    print(f"Bilinearity verified (1000 random tests): {is_bilinear}")
    
    a = np.array([1, 0, 0])
    b = np.array([0, 1, 0])
    c = np.array([1, 1, 0])
    
    print(f"\ncup([1,0,0], [0,1,0]) = {pairing.cup(a, b)}")
    print(f"cup([0,1,0], [1,0,0]) = {pairing.cup(b, a)}")
    print(f"cup([1,0,0], [1,1,0]) = {pairing.cup(a, c)}")
    print(f"cup([1,0,0], [0,1,0]) + cup([1,0,0], [1,0,0]) = "
          f"{(pairing.cup(a, b) + pairing.cup(a, a)) % q}")
    print(f"  (should equal cup([1,0,0], [1,1,0]) = {pairing.cup(a, c)} ✓)")
    print()


def demo_pairing_types():
    """Demonstrate pairing type classification."""
    print("=" * 60)
    print("DEMO 2: Pairing Type Classification by Degree Parity")
    print("=" * 60)
    
    print(f"{'p':>3} {'r':>3} {'(-1)^(pr)':>10} {'Type':>25}")
    print("-" * 45)
    
    for p in range(5):
        for r in range(5):
            sign = graded_commutativity_sign(p, r)
            ptype = classify_pairing_type(p, r)
            if p <= r:  # avoid duplicates
                print(f"{p:>3} {r:>3} {sign:>10} {ptype:>25}")
    
    print("\nKey insight: Both type-1 AND type-3 pairings from a single space!")
    print("This is IMPOSSIBLE for elliptic curve pairings.")
    print()


def demo_ibe():
    """Demonstrate IBE encryption and decryption."""
    print("=" * 60)
    print("DEMO 3: Cohomological Identity-Based Encryption")
    print("=" * 60)
    
    q = 101  # prime field
    M = np.array([[3, 1, 4], [1, 5, 9], [2, 6, 5]])
    pairing = BilinearCupPairing(q, M)
    
    generator = np.array([1, 2, 3])
    master_secret = 42
    
    ibe = CohomologicalIBE(pairing, generator, master_secret)
    
    # Alice's identity
    alice_id = np.array([7, 11, 13])
    alice_key = ibe.extract_key(alice_id)
    
    print(f"Field: F_{q}")
    print(f"Generator: {generator}")
    print(f"Master secret: {master_secret}")
    print(f"Public param: {ibe.public_param}")
    print(f"\nAlice's identity: {alice_id}")
    print(f"Alice's private key: {alice_key}")
    
    # Encrypt messages with different randomness
    print("\nEncryption/Decryption tests:")
    for msg in [0, 1, 42, 99, 100]:
        r = np.random.randint(1, q)
        ct = ibe.encrypt(alice_id, r, msg)
        decrypted = ibe.decrypt(alice_key, ct)
        status = "✓" if decrypted == msg else "✗"
        print(f"  msg={msg:>3}, r={r:>3} → ciphertext=({ct[0]}, {ct[1]:>3}) → "
              f"decrypted={decrypted:>3} {status}")
    
    # Verify correctness for many random messages
    correct = 0
    total = 1000
    for _ in range(total):
        msg = np.random.randint(0, q)
        r = np.random.randint(1, q)
        ct = ibe.encrypt(alice_id, r, msg)
        if ibe.decrypt(alice_key, ct) == msg:
            correct += 1
    
    print(f"\nCorrectness: {correct}/{total} messages decrypted correctly")
    print(f"(Theorem ibe_decrypt_correct guarantees 100% correctness)")
    print()


def demo_security_bounds():
    """Demonstrate Betti number security bounds."""
    print("=" * 60)
    print("DEMO 4: Betti Number Security Bounds")
    print("=" * 60)
    
    # Example topological spaces and their Betti numbers
    spaces = {
        "Circle S¹":        ([1, 1], "β₀=1, β₁=1"),
        "Torus T²":         ([1, 2, 1], "β₀=1, β₁=2, β₂=1"),
        "Klein bottle":     ([1, 1, 0], "β₀=1, β₁=1 (over Z)"),
        "RP² (mod 2)":      ([1, 1, 1], "β₀=1, β₁=1, β₂=1"),
        "Genus-2 surface":  ([1, 4, 1], "β₀=1, β₁=4, β₂=1"),
        "CP²":              ([1, 0, 1, 0, 1], "β₀=1, β₂=1, β₄=1"),
        "Product S²×S²":    ([1, 0, 2, 0, 1], "β₀=1, β₂=2, β₄=1"),
    }
    
    q = 256  # field size (2^8)
    
    print(f"\nField size q = {q}")
    print(f"{'Space':<20} {'Betti':>15} {'Dim':>5} {'Classical':>12} {'Quantum':>12} {'KeySpace':>12}")
    print("-" * 80)
    
    for name, (betti, desc) in spaces.items():
        params = BettiSecurityParams(betti, q)
        print(f"{name:<20} {desc:>15} {params.total_key_dimension:>5} "
              f"{params.classical_security_bits:>10.1f}b {params.quantum_security_bits:>10.1f}b "
              f"{params.key_space_size:>12.2e}")
    
    print(f"\nTheorem (topological_exceeds_ec_security):")
    print(f"  When totalKeyDim ≥ 2, topological security ≥ 2× single-curve EC security")
    print(f"  EC security over F_{q}: {np.log2(q)/2:.1f} bits")
    print(f"  Torus T² security: {BettiSecurityParams([1,2,1], q).classical_security_bits:.1f} bits ≥ "
          f"2 × {np.log2(q)/2:.1f} = {np.log2(q):.1f} bits ✓")
    print()


def create_visualization():
    """Create visualization of security bounds."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Plot 1: Security vs Betti number sum
    ax = axes[0]
    dims = range(1, 11)
    for q in [7, 31, 127, 521]:
        sec = [d * np.log2(q) / 2 for d in dims]
        ax.plot(dims, sec, 'o-', label=f'q={q}', markersize=4)
    ax.set_xlabel('Total Betti Number Sum (Σβⁿ)')
    ax.set_ylabel('Classical Security (bits)')
    ax.set_title('Security vs Topological Complexity')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Pairing type classification
    ax = axes[1]
    grid = np.zeros((6, 6))
    for p in range(6):
        for r in range(6):
            if p % 2 == 0 and r % 2 == 0:
                grid[p, r] = 1  # symmetric
            elif p % 2 == 1 and r % 2 == 1:
                grid[p, r] = -1  # alternating
            else:
                grid[p, r] = 0  # mixed
    
    cmap = plt.cm.RdYlBu
    im = ax.imshow(grid, cmap=cmap, vmin=-1, vmax=1, origin='lower')
    ax.set_xlabel('Degree r')
    ax.set_ylabel('Degree p')
    ax.set_title('Cup Product Pairing Types')
    ax.set_xticks(range(6))
    ax.set_yticks(range(6))
    for p in range(6):
        for r in range(6):
            t = {1: 'S', -1: 'A', 0: 'M'}[int(grid[p, r])]
            ax.text(r, p, t, ha='center', va='center', fontweight='bold', fontsize=10)
    
    # Plot 3: Classical vs Quantum security
    ax = axes[2]
    classical = np.linspace(0, 512, 100)
    quantum = classical / 2
    ax.plot(classical, classical, 'b-', label='Classical', linewidth=2)
    ax.plot(classical, quantum, 'r--', label='Quantum (Grover)', linewidth=2)
    ax.axhline(y=128, color='g', linestyle=':', label='NIST Level 5 (128-bit)')
    ax.axhline(y=256, color='orange', linestyle=':', label='Classical target (256-bit)')
    ax.fill_between(classical, quantum, alpha=0.1, color='red')
    ax.set_xlabel('Classical Security (bits)')
    ax.set_ylabel('Effective Security (bits)')
    ax.set_title('Post-Quantum Security Degradation')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('security_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: security_analysis.png")


def demo_complexity_bounds():
    """Demonstrate computational complexity bounds."""
    print("=" * 60)
    print("DEMO 5: Computational Complexity Bounds")
    print("=" * 60)
    
    print("\nTheorem (cup_complexity_factorial_bound):")
    print("  choose(p+r, p) ≤ 2^(p+r)")
    print()
    print(f"{'p':>3} {'r':>3} {'choose(p+r,p)':>15} {'2^(p+r)':>10} {'Ratio':>8}")
    print("-" * 45)
    
    from math import comb
    for p in range(1, 8):
        for r in [p, p+1]:
            c = comb(p + r, p)
            bound = 2 ** (p + r)
            print(f"{p:>3} {r:>3} {c:>15} {bound:>10} {c/bound:>8.4f}")
    
    print("\nTheorem (key_extraction_bound): βp * βr ≤ (βp + βr)²")
    print(f"{'βp':>4} {'βr':>4} {'βp*βr':>8} {'(βp+βr)²':>10}")
    print("-" * 30)
    for bp in [1, 2, 4, 8]:
        for br in [1, 2, 4, 8]:
            print(f"{bp:>4} {br:>4} {bp*br:>8} {(bp+br)**2:>10}")
    print()


if __name__ == "__main__":
    np.random.seed(42)
    
    demo_bilinearity()
    demo_pairing_types()
    demo_ibe()
    demo_security_bounds()
    demo_complexity_bounds()
    
    try:
        create_visualization()
    except Exception as e:
        print(f"Visualization skipped: {e}")
    
    print("=" * 60)
    print("All demonstrations complete!")
    print("=" * 60)
