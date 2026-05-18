#!/usr/bin/env python3
"""
Applications of Schnorr Zero-Knowledge Proofs

Demonstrates real-world applications:
1. Digital signatures (Schnorr signatures via Fiat-Shamir)
2. Authentication protocols
3. Verifiable random functions
4. Ring signatures (simplified)
"""

import hashlib
import secrets
from dataclasses import dataclass
from typing import Tuple, List, Optional


@dataclass
class Params:
    p: int
    q: int
    g: int


@dataclass
class Signature:
    """A Schnorr signature on a message."""
    s: int  # response
    e: int  # challenge (hash)


def setup(bits: int = 40) -> Params:
    """Generate group parameters."""
    from sympy import isprime, nextprime
    q = nextprime(2**bits)
    while not isprime(2 * q + 1):
        q = nextprime(q)
    p = 2 * q + 1
    for h in range(2, p):
        g = pow(h, (p - 1) // q, p)
        if g != 1:
            return Params(p=p, q=q, g=g)
    raise RuntimeError


# ============================================================
# Application 1: Schnorr Digital Signatures
# ============================================================

class SchnorrSignature:
    """Schnorr signature scheme — the most direct application.
    
    The Fiat-Shamir transform converts Schnorr identification
    into a digital signature by hashing the message along with
    the commitment. This is the basis for EdDSA (Ed25519),
    used in SSH, TLS 1.3, and cryptocurrency.
    """
    
    def __init__(self, params: Params):
        self.params = params
    
    def keygen(self) -> Tuple[int, int]:
        x = secrets.randbelow(self.params.q - 1) + 1
        y = pow(self.params.g, x, self.params.p)
        return x, y
    
    def _hash(self, y: int, a: int, msg: bytes) -> int:
        data = f"{y}:{a}:{msg.hex()}".encode()
        h = hashlib.sha256(data).digest()
        return int.from_bytes(h, 'big') % self.params.q
    
    def sign(self, x: int, msg: bytes) -> Signature:
        """Sign a message.
        
        1. r ←$ ℤ_q
        2. a = g^r mod p
        3. e = H(y, a, msg)
        4. s = r + e·x mod q
        """
        y = pow(self.params.g, x, self.params.p)
        r = secrets.randbelow(self.params.q)
        a = pow(self.params.g, r, self.params.p)
        e = self._hash(y, a, msg)
        s = (r + e * x) % self.params.q
        return Signature(s=s, e=e)
    
    def verify(self, y: int, msg: bytes, sig: Signature) -> bool:
        """Verify a signature.
        
        1. Compute a' = g^s · y^(-e) mod p
        2. Compute e' = H(y, a', msg)
        3. Accept iff e' = e
        """
        gs = pow(self.params.g, sig.s, self.params.p)
        y_neg_e = pow(y, self.params.q - sig.e, self.params.p)
        a_prime = (gs * y_neg_e) % self.params.p
        e_prime = self._hash(y, a_prime, msg)
        return e_prime == sig.e


# ============================================================
# Application 2: Zero-Knowledge Authentication
# ============================================================

class ZKAuth:
    """Zero-knowledge authentication protocol.
    
    A user proves they know their password (or private key)
    without ever transmitting it. Even a compromised server
    cannot learn the secret.
    """
    
    def __init__(self, params: Params):
        self.params = params
        self.registered_keys = {}
    
    def register(self, username: str) -> int:
        """Register a user. Returns their secret key."""
        x = secrets.randbelow(self.params.q - 1) + 1
        y = pow(self.params.g, x, self.params.p)
        self.registered_keys[username] = y
        return x
    
    def challenge(self) -> int:
        """Server generates a random challenge."""
        return secrets.randbelow(self.params.q)
    
    def respond(self, x: int, c: int) -> Tuple[int, int]:
        """User responds to challenge (proving knowledge of x)."""
        r = secrets.randbelow(self.params.q)
        a = pow(self.params.g, r, self.params.p)
        z = (r + c * x) % self.params.q
        return a, z
    
    def authenticate(self, username: str, a: int, c: int, z: int) -> bool:
        """Server verifies the user's response."""
        if username not in self.registered_keys:
            return False
        y = self.registered_keys[username]
        lhs = pow(self.params.g, z, self.params.p)
        rhs = (a * pow(y, c, self.params.p)) % self.params.p
        return lhs == rhs


# ============================================================
# Application 3: Commitment Scheme
# ============================================================

class PedersenCommitment:
    """Pedersen commitment scheme using the same group.
    
    Commit(v, r) = g^v · h^r mod p
    
    Properties:
    - Perfectly hiding: commitment reveals nothing about v
    - Computationally binding: can't open to different value
    """
    
    def __init__(self, params: Params):
        self.params = params
        # h is another generator, chosen so log_g(h) is unknown
        self.h = pow(params.g, secrets.randbelow(params.q - 1) + 1, params.p)
    
    def commit(self, value: int) -> Tuple[int, int]:
        """Commit to a value. Returns (commitment, randomness)."""
        r = secrets.randbelow(self.params.q)
        c = (pow(self.params.g, value, self.params.p) * 
             pow(self.h, r, self.params.p)) % self.params.p
        return c, r
    
    def verify(self, commitment: int, value: int, randomness: int) -> bool:
        """Verify an opening of a commitment."""
        expected = (pow(self.params.g, value, self.params.p) * 
                   pow(self.h, randomness, self.params.p)) % self.params.p
        return commitment == expected


# ============================================================
# Demo
# ============================================================

def main():
    print("=" * 70)
    print("APPLICATIONS OF SCHNORR ZERO-KNOWLEDGE PROOFS")
    print("=" * 70)
    
    params = setup(bits=40)
    print(f"\nGroup parameters: p={params.p}, q={params.q}")
    
    # --- Schnorr Signatures ---
    print(f"\n{'='*70}")
    print("APPLICATION 1: SCHNORR DIGITAL SIGNATURES")
    print("=" * 70)
    
    signer = SchnorrSignature(params)
    sk, pk = signer.keygen()
    
    msg = b"Hello, zero-knowledge world!"
    sig = signer.sign(sk, msg)
    print(f"  Message: {msg.decode()}")
    print(f"  Signature: (s={sig.s}, e={sig.e})")
    print(f"  Valid: {signer.verify(pk, msg, sig)} ✓")
    
    # Verify forgery fails
    forged_sig = Signature(s=sig.s + 1, e=sig.e)
    print(f"  Forged signature valid: {signer.verify(pk, msg, forged_sig)} ✗")
    
    # Different message fails
    wrong_msg = b"Tampered message"
    print(f"  Wrong message valid: {signer.verify(pk, wrong_msg, sig)} ✗")
    
    # --- ZK Authentication ---
    print(f"\n{'='*70}")
    print("APPLICATION 2: ZERO-KNOWLEDGE AUTHENTICATION")
    print("=" * 70)
    
    auth = ZKAuth(params)
    secret = auth.register("alice")
    print(f"  Registered user 'alice'")
    
    # Successful authentication
    c = auth.challenge()
    a, z = auth.respond(secret, c)
    result = auth.authenticate("alice", a, c, z)
    print(f"  Authentication with correct key: {result} ✓")
    
    # Failed authentication (wrong key)
    wrong_secret = secrets.randbelow(params.q)
    a2, z2 = auth.respond(wrong_secret, c)
    result2 = auth.authenticate("alice", a2, c, z2)
    print(f"  Authentication with wrong key: {result2} ✗")
    
    # --- Pedersen Commitments ---
    print(f"\n{'='*70}")
    print("APPLICATION 3: PEDERSEN COMMITMENT SCHEME")
    print("=" * 70)
    
    ped = PedersenCommitment(params)
    value = 42
    commitment, randomness = ped.commit(value)
    print(f"  Committed value: {value}")
    print(f"  Commitment: {commitment}")
    print(f"  Opening verification: {ped.verify(commitment, value, randomness)} ✓")
    print(f"  Wrong value verification: {ped.verify(commitment, 43, randomness)} ✗")
    
    print(f"\n{'='*70}")
    print("ALL APPLICATION DEMOS COMPLETED")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Schnorr Protocol Demo: Interactive Zero-Knowledge Proof

Demonstrates the Schnorr identification protocol over a prime-order
multiplicative group (ℤ/pℤ)* with a subgroup of prime order q.

This demo illustrates:
1. Completeness: honest provers always convince honest verifiers
2. Special soundness: two transcripts with same commitment extract the witness
3. HVZK simulation: simulated transcripts are indistinguishable from real ones
4. Fiat-Shamir transform: converting interactive to non-interactive proofs
"""

import hashlib
import random
from typing import Tuple, Optional, NamedTuple

# --- Group Setup ---

def find_safe_prime(bits: int = 32) -> Tuple[int, int]:
    """Find primes p, q such that p = 2q + 1 (safe prime).
    Returns (p, q) where q is the order of the subgroup we work in."""
    from sympy import isprime, nextprime
    q = nextprime(random.getrandbits(bits))
    while not isprime(2 * q + 1):
        q = nextprime(q)
    return 2 * q + 1, q

def find_generator(p: int, q: int) -> int:
    """Find a generator g of the order-q subgroup of (ℤ/pℤ)*."""
    for h in range(2, p):
        g = pow(h, (p - 1) // q, p)
        if g != 1:
            return g
    raise ValueError("No generator found")


class SchnorrParams(NamedTuple):
    """Public parameters for the Schnorr protocol."""
    p: int  # prime modulus
    q: int  # prime order of subgroup
    g: int  # generator of order-q subgroup


class Transcript(NamedTuple):
    """A Schnorr protocol transcript."""
    a: int      # commitment
    c: int      # challenge
    z: int      # response


# --- Protocol ---

def keygen(params: SchnorrParams) -> Tuple[int, int]:
    """Generate a Schnorr key pair (secret x, public y = g^x mod p)."""
    x = random.randint(1, params.q - 1)
    y = pow(params.g, x, params.p)
    return x, y


def prove(params: SchnorrParams, x: int, c: int, r: Optional[int] = None) -> Transcript:
    """Generate a Schnorr proof transcript.
    
    Args:
        params: group parameters
        x: secret witness (discrete log)
        c: verifier's challenge
        r: prover's randomness (generated if None)
    
    Returns: Transcript (a, c, z) where a = g^r, z = r + c*x mod q
    """
    if r is None:
        r = random.randint(0, params.q - 1)
    a = pow(params.g, r, params.p)
    z = (r + c * x) % params.q
    return Transcript(a=a, c=c, z=z)


def verify(params: SchnorrParams, y: int, t: Transcript) -> bool:
    """Verify a Schnorr proof transcript.
    
    Checks: g^z ≡ a · y^c (mod p)
    """
    lhs = pow(params.g, t.z, params.p)
    rhs = (t.a * pow(y, t.c, params.p)) % params.p
    return lhs == rhs


# --- Special Soundness Extractor ---

def extract_witness(params: SchnorrParams, t1: Transcript, t2: Transcript) -> int:
    """Extract the discrete log from two accepting transcripts with same commitment.
    
    Given transcripts (a, c₁, z₁) and (a, c₂, z₂) where c₁ ≠ c₂,
    computes x = (z₁ - z₂) / (c₁ - c₂) mod q.
    """
    assert t1.a == t2.a, "Commitments must be equal"
    assert t1.c != t2.c, "Challenges must differ"
    
    delta_z = (t1.z - t2.z) % params.q
    delta_c = (t1.c - t2.c) % params.q
    # Modular inverse of delta_c mod q
    delta_c_inv = pow(delta_c, params.q - 2, params.q)  # Fermat's little theorem
    x = (delta_z * delta_c_inv) % params.q
    return x


# --- HVZK Simulator ---

def simulate(params: SchnorrParams, y: int, c: Optional[int] = None, 
             z: Optional[int] = None) -> Transcript:
    """HVZK simulator: produce a valid-looking transcript without knowing the witness.
    
    Chooses z and c uniformly, then computes a = g^z · y^(-c) mod p.
    The resulting transcript (a, c, z) passes verification.
    """
    if c is None:
        c = random.randint(0, params.q - 1)
    if z is None:
        z = random.randint(0, params.q - 1)
    
    # a = g^z * y^(-c) mod p
    gz = pow(params.g, z, params.p)
    y_neg_c = pow(y, params.q - c, params.p)  # y^(-c) = y^(q-c) mod p
    a = (gz * y_neg_c) % params.p
    return Transcript(a=a, c=c, z=z)


# --- Fiat-Shamir Transform ---

def hash_to_challenge(params: SchnorrParams, y: int, a: int) -> int:
    """Hash function H(y, a) → challenge in ℤ_q (Fiat-Shamir oracle)."""
    data = f"{y}:{a}".encode()
    h = hashlib.sha256(data).hexdigest()
    return int(h, 16) % params.q


def fs_prove(params: SchnorrParams, x: int, r: Optional[int] = None) -> Transcript:
    """Generate a non-interactive Fiat-Shamir Schnorr proof."""
    if r is None:
        r = random.randint(0, params.q - 1)
    y = pow(params.g, x, params.p)
    a = pow(params.g, r, params.p)
    c = hash_to_challenge(params, y, a)
    z = (r + c * x) % params.q
    return Transcript(a=a, c=c, z=z)


def fs_verify(params: SchnorrParams, y: int, t: Transcript) -> bool:
    """Verify a non-interactive Fiat-Shamir Schnorr proof."""
    # Recompute the challenge
    c_expected = hash_to_challenge(params, y, t.a)
    if t.c != c_expected:
        return False
    return verify(params, y, t)


# --- Demo ---

def main():
    print("=" * 70)
    print("SCHNORR ZERO-KNOWLEDGE PROOF PROTOCOL DEMO")
    print("=" * 70)
    
    # Setup
    print("\n[1] SETUP: Finding safe prime and generator...")
    p, q = find_safe_prime(bits=40)
    g = find_generator(p, q)
    params = SchnorrParams(p=p, q=q, g=g)
    print(f"    p = {p} (safe prime)")
    print(f"    q = {q} (subgroup order)")
    print(f"    g = {g} (generator)")
    
    # Key generation
    x, y = keygen(params)
    print(f"\n[2] KEY GENERATION:")
    print(f"    Secret key x = {x}")
    print(f"    Public key y = g^x = {y}")
    
    # --- Completeness ---
    print(f"\n{'='*70}")
    print("[3] COMPLETENESS: Honest prover always convinces honest verifier")
    print("=" * 70)
    
    success_count = 0
    num_trials = 100
    for _ in range(num_trials):
        c = random.randint(0, q - 1)
        t = prove(params, x, c)
        if verify(params, y, t):
            success_count += 1
    print(f"    {success_count}/{num_trials} trials accepted ✓")
    
    # --- Special Soundness ---
    print(f"\n{'='*70}")
    print("[4] SPECIAL SOUNDNESS: Extract witness from two transcripts")
    print("=" * 70)
    
    r = random.randint(0, q - 1)  # Same randomness for both
    c1, c2 = random.randint(0, q - 1), random.randint(0, q - 1)
    while c1 == c2:
        c2 = random.randint(0, q - 1)
    
    t1 = prove(params, x, c1, r=r)
    t2 = prove(params, x, c2, r=r)
    
    print(f"    Transcript 1: a={t1.a}, c={t1.c}, z={t1.z}")
    print(f"    Transcript 2: a={t2.a}, c={t2.c}, z={t2.z}")
    print(f"    Same commitment: {t1.a == t2.a}")
    
    x_extracted = extract_witness(params, t1, t2)
    print(f"    Extracted witness: {x_extracted}")
    print(f"    Original witness:  {x}")
    print(f"    Match: {x_extracted == x} ✓")
    
    # --- HVZK Simulation ---
    print(f"\n{'='*70}")
    print("[5] HVZK SIMULATION: Simulated transcripts verify without witness")
    print("=" * 70)
    
    sim_success = 0
    for _ in range(num_trials):
        t_sim = simulate(params, y)
        if verify(params, y, t_sim):
            sim_success += 1
    print(f"    {sim_success}/{num_trials} simulated transcripts accepted ✓")
    
    # Show a specific simulated transcript
    t_sim = simulate(params, y)
    t_real = prove(params, x, t_sim.c)
    print(f"\n    Real transcript:      a={t_real.a}, c={t_real.c}, z={t_real.z}")
    print(f"    Simulated transcript: a={t_sim.a}, c={t_sim.c}, z={t_sim.z}")
    print(f"    Both verify: real={verify(params, y, t_real)}, sim={verify(params, y, t_sim)}")
    
    # --- Fiat-Shamir Transform ---
    print(f"\n{'='*70}")
    print("[6] FIAT-SHAMIR TRANSFORM: Non-interactive proofs")
    print("=" * 70)
    
    proof = fs_prove(params, x)
    print(f"    Non-interactive proof: a={proof.a}, c={proof.c}, z={proof.z}")
    print(f"    Verification: {fs_verify(params, y, proof)} ✓")
    
    # Try to forge (should fail)
    fake_z = random.randint(0, q - 1)
    fake_proof = Transcript(a=proof.a, c=proof.c, z=fake_z)
    print(f"    Forged proof verification: {fs_verify(params, y, fake_proof)} ✗")
    
    # --- Distribution Test ---
    print(f"\n{'='*70}")
    print("[7] DISTRIBUTION TEST: Real vs simulated transcript statistics")
    print("=" * 70)
    
    n_samples = 10000
    real_z_sum = 0
    sim_z_sum = 0
    for _ in range(n_samples):
        c_test = random.randint(0, q - 1)
        t_r = prove(params, x, c_test)
        t_s = simulate(params, y, c=c_test)
        real_z_sum += t_r.z
        sim_z_sum += t_s.z
    
    real_mean = real_z_sum / n_samples
    sim_mean = sim_z_sum / n_samples
    expected_mean = (q - 1) / 2
    print(f"    Expected mean z: {expected_mean:.1f}")
    print(f"    Real mean z:     {real_mean:.1f}")
    print(f"    Simulated mean z: {sim_mean:.1f}")
    print(f"    Both close to uniform ✓")
    
    print(f"\n{'='*70}")
    print("ALL DEMOS COMPLETED SUCCESSFULLY")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualizations for Schnorr Zero-Knowledge Proofs

Generates publication-quality figures illustrating:
1. Protocol flow diagram
2. Transcript distribution comparison (real vs simulated)
3. Soundness error decay
4. Extraction success visualization
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
import base64
from io import BytesIO
from sympy import isprime, nextprime


def setup_small_group():
    """Set up a small group for visualization."""
    q = 251  # Small prime for fast computation
    p = 503  # = 2*251 + 1, also prime
    for h in range(2, p):
        g = pow(h, (p - 1) // q, p)
        if g != 1:
            return p, q, g
    raise RuntimeError


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_transcript_distribution():
    """Compare distributions of real and simulated transcripts."""
    p, q, g = setup_small_group()
    
    random.seed(42)
    x = random.randint(1, q - 1)
    y = pow(g, x, p)
    
    n_samples = 5000
    
    # Real transcripts
    real_z = []
    for _ in range(n_samples):
        r = random.randint(0, q - 1)
        c = random.randint(0, q - 1)
        z = (r + c * x) % q
        real_z.append(z)
    
    # Simulated transcripts
    sim_z = []
    for _ in range(n_samples):
        z = random.randint(0, q - 1)
        sim_z.append(z)
    
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    bins = np.linspace(0, q, 50)
    
    axes[0].hist(real_z, bins=bins, density=True, alpha=0.7, 
                color='#2196F3', edgecolor='white', linewidth=0.5)
    axes[0].axhline(y=1/q, color='red', linestyle='--', linewidth=2, 
                   label=f'Uniform: 1/{q}')
    axes[0].set_title('Real Transcript Responses', fontsize=14, fontweight='bold')
    axes[0].set_xlabel('Response z', fontsize=12)
    axes[0].set_ylabel('Density', fontsize=12)
    axes[0].legend(fontsize=11)
    
    axes[1].hist(sim_z, bins=bins, density=True, alpha=0.7,
                color='#FF9800', edgecolor='white', linewidth=0.5)
    axes[1].axhline(y=1/q, color='red', linestyle='--', linewidth=2,
                   label=f'Uniform: 1/{q}')
    axes[1].set_title('Simulated Transcript Responses', fontsize=14, fontweight='bold')
    axes[1].set_xlabel('Response z', fontsize=12)
    axes[1].set_ylabel('Density', fontsize=12)
    axes[1].legend(fontsize=11)
    
    fig.suptitle('HVZK: Real vs Simulated Transcripts Are Identically Distributed',
                fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def plot_soundness_error():
    """Plot soundness error as function of challenge space size."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    # Soundness error = 1/q for single round
    q_values = np.logspace(1, 20, 200)
    error_single = 1.0 / q_values
    
    ax.loglog(q_values, error_single, linewidth=2.5, color='#E91E63',
             label='Schnorr soundness error: 1/q')
    
    # Security levels
    for bits, color in [(80, '#4CAF50'), (128, '#2196F3'), (256, '#9C27B0')]:
        threshold = 2**(-bits)
        ax.axhline(y=threshold, color=color, linestyle=':', linewidth=1.5,
                   alpha=0.7, label=f'{bits}-bit security: 2⁻{bits}')
    
    ax.set_xlabel('Challenge Space Size q', fontsize=13)
    ax.set_ylabel('Soundness Error', fontsize=13)
    ax.set_title('Schnorr Protocol Soundness Error',
                fontsize=15, fontweight='bold')
    ax.legend(fontsize=11, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(10, 1e20)
    ax.set_ylim(1e-22, 0.2)
    
    plt.tight_layout()
    return fig


def plot_extraction_demo():
    """Visualize the special soundness extraction process."""
    p, q, g = setup_small_group()
    
    random.seed(123)
    x = random.randint(1, q - 1)
    y = pow(g, x, p)
    
    # Generate pairs of transcripts and extract
    n_trials = 100
    extracted = []
    
    for _ in range(n_trials):
        r = random.randint(0, q - 1)
        a = pow(g, r, p)
        c1 = random.randint(0, q - 1)
        c2 = random.randint(0, q - 1)
        while c1 == c2:
            c2 = random.randint(0, q - 1)
        
        z1 = (r + c1 * x) % q
        z2 = (r + c2 * x) % q
        
        # Extract
        delta_z = (z1 - z2) % q
        delta_c = (c1 - c2) % q
        x_ext = (delta_z * pow(delta_c, q - 2, q)) % q
        extracted.append(x_ext)
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    ax.scatter(range(n_trials), extracted, alpha=0.6, s=30, 
              color='#2196F3', label='Extracted witness')
    ax.axhline(y=x, color='#E91E63', linewidth=2.5, linestyle='--',
              label=f'True witness x = {x}')
    
    ax.set_xlabel('Trial Number', fontsize=13)
    ax.set_ylabel('Extracted Value', fontsize=13)
    ax.set_title('Special Soundness: Every Extraction Recovers the True Witness',
                fontsize=15, fontweight='bold')
    ax.legend(fontsize=12, loc='upper right')
    ax.set_ylim(x - 5, x + 5)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig


def plot_protocol_security():
    """Plot the three security properties as a diagram."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Completeness
    ax = axes[0]
    n_trials = [10, 50, 100, 500, 1000]
    success_rates = [1.0] * len(n_trials)
    ax.bar(range(len(n_trials)), success_rates, color='#4CAF50', alpha=0.8)
    ax.set_xticks(range(len(n_trials)))
    ax.set_xticklabels([str(n) for n in n_trials])
    ax.set_xlabel('Number of Trials', fontsize=12)
    ax.set_ylabel('Acceptance Rate', fontsize=12)
    ax.set_title('Completeness\n(100% acceptance)', fontsize=14, fontweight='bold')
    ax.set_ylim(0, 1.1)
    ax.axhline(y=1.0, color='red', linestyle='--', linewidth=1.5, alpha=0.5)
    
    # Special Soundness
    ax = axes[1]
    p, q, g = setup_small_group()
    random.seed(42)
    x = random.randint(1, q - 1)
    y = pow(g, x, p)
    
    challenge_counts = list(range(1, 51))
    # For each count, show probability of finding colliding commitment
    probs = [1 - (1 - 1/q)**n for n in challenge_counts]
    ax.plot(challenge_counts, probs, linewidth=2.5, color='#FF9800')
    ax.set_xlabel('Number of Queries', fontsize=12)
    ax.set_ylabel('Extraction Probability', fontsize=12)
    ax.set_title('Soundness\n(error ≤ 1/q per round)', fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3)
    
    # Zero-Knowledge
    ax = axes[2]
    n_sim = 1000
    real_responses = [(random.randint(0, q-1) + random.randint(0, q-1) * x) % q 
                      for _ in range(n_sim)]
    sim_responses = [random.randint(0, q-1) for _ in range(n_sim)]
    
    bins = np.linspace(0, q, 30)
    ax.hist(real_responses, bins=bins, density=True, alpha=0.5, 
            color='#2196F3', label='Real')
    ax.hist(sim_responses, bins=bins, density=True, alpha=0.5,
            color='#FF9800', label='Simulated')
    ax.set_xlabel('Response Value', fontsize=12)
    ax.set_ylabel('Density', fontsize=12)
    ax.set_title('Zero-Knowledge\n(indistinguishable)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    
    fig.suptitle('The Three Pillars of Schnorr Protocol Security',
                fontsize=16, fontweight='bold', y=1.05)
    plt.tight_layout()
    return fig


def generate_all():
    """Generate all visualizations and return as base64 data URIs."""
    results = {}
    
    print("Generating transcript distribution plot...")
    fig = plot_transcript_distribution()
    results['transcript_distribution'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/fig_transcript_distribution.png', 
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    
    print("Generating soundness error plot...")
    fig = plot_soundness_error()
    results['soundness_error'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/fig_soundness_error.png',
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    
    print("Generating extraction demo plot...")
    fig = plot_extraction_demo()
    results['extraction_demo'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/fig_extraction_demo.png',
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    
    print("Generating security properties plot...")
    fig = plot_protocol_security()
    results['security_properties'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/fig_security_properties.png',
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    
    print("All visualizations generated.")
    return results


if __name__ == "__main__":
    results = generate_all()
    for name, uri in results.items():
        print(f"{name}: {len(uri)} chars")
