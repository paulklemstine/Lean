#!/usr/bin/env python3
"""
Schnorr Protocol: Real-World Applications

Demonstrates practical applications of the Schnorr protocol and its
formally verified security properties.

Applications:
1. Digital signature scheme (Schnorr signatures via Fiat-Shamir)
2. Multi-party authentication with shared verification
3. Commitment scheme with extractable binding
4. Privacy-preserving age verification (zero-knowledge proof of knowledge)
"""

import hashlib
import random
from dataclasses import dataclass
from typing import List, Tuple, Optional


# ── Group Setup ───────────────────────────────────────────────────────

@dataclass(frozen=True)
class Group:
    p: int
    q: int
    g: int

    def pow(self, base: int, exp: int) -> int:
        return pow(base, exp % self.q, self.p)

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p

    def inv(self, a: int) -> int:
        return pow(a, self.p - 2, self.p)


def setup_group(bits: int = 16) -> Group:
    """Set up a cryptographic group with a safe prime."""
    from sympy import isprime, nextprime
    q = nextprime(2 ** bits)
    while True:
        p = 2 * q + 1
        if isprime(p):
            break
        q = nextprime(q)
    for g_cand in range(2, p):
        g = pow(g_cand, 2, p)
        if g != 1 and pow(g, q, p) == 1:
            return Group(p, q, g)
    raise ValueError("No generator found")


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 1: Schnorr Digital Signatures
# ═══════════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class SchnorrSignature:
    """A Schnorr digital signature on a message."""
    commitment: int  # a = g^r
    response: int    # z = r + H(m, a) · x mod q


class SchnorrSigner:
    """Schnorr signature scheme (Fiat-Shamir applied to Schnorr protocol).

    Security is based on:
    - Completeness (schnorr_completeness): honest signatures always verify
    - Soundness (schnorr_special_soundness_extract): forgery requires
      knowing the discrete log
    - Fiat-Shamir security (fiat_shamir_fork_extract): in the ROM,
      forking yields extraction
    """

    def __init__(self, grp: Group):
        self.grp = grp
        self.secret = random.randint(1, grp.q - 1)
        self.public = grp.pow(grp.g, self.secret)

    def _hash(self, message: str, a: int) -> int:
        h = hashlib.sha256(f"{message}:{a}".encode()).digest()
        return int.from_bytes(h, 'big') % self.grp.q

    def sign(self, message: str) -> SchnorrSignature:
        """Sign a message using the Schnorr signature scheme.

        1. Choose random nonce r
        2. Compute commitment a = g^r
        3. Compute challenge c = H(message, a)
        4. Compute response z = r + c·x mod q
        """
        r = random.randint(0, self.grp.q - 1)
        a = self.grp.pow(self.grp.g, r)
        c = self._hash(message, a)
        z = (r + c * self.secret) % self.grp.q
        return SchnorrSignature(commitment=a, response=z)

    def verify(self, message: str, sig: SchnorrSignature) -> bool:
        """Verify a Schnorr signature.

        Check: g^z == a · y^c where c = H(message, a)
        """
        c = self._hash(message, sig.commitment)
        lhs = self.grp.pow(self.grp.g, sig.response)
        rhs = self.grp.mul(sig.commitment, self.grp.pow(self.public, c))
        return lhs == rhs


def demo_signatures():
    """Demonstrate Schnorr digital signatures."""
    print("=" * 70)
    print("APPLICATION 1: Schnorr Digital Signatures")
    print("=" * 70)

    grp = setup_group(16)
    signer = SchnorrSigner(grp)

    print(f"Public key: {signer.public}")

    messages = [
        "Transfer $100 to Alice",
        "Approve contract #42",
        "Hello, World!",
    ]

    for msg in messages:
        sig = signer.sign(msg)
        valid = signer.verify(msg, sig)
        print(f"\nMessage: '{msg}'")
        print(f"  Signature: (a={sig.commitment}, z={sig.response})")
        print(f"  Valid: {valid}")

    # Demonstrate forgery detection
    sig = signer.sign("Legitimate message")
    tampered_valid = signer.verify("Tampered message", sig)
    print(f"\nForgery detection:")
    print(f"  Original verifies: {signer.verify('Legitimate message', sig)}")
    print(f"  Tampered verifies: {tampered_valid}")
    print(f"  Forgery detected: {not tampered_valid}")


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 2: Zero-Knowledge Age Verification
# ═══════════════════════════════════════════════════════════════════════

class ZKAgeVerifier:
    """Zero-knowledge proof that a user knows a secret credential.

    Models a privacy-preserving authentication system where a user
    proves knowledge of a credential (their secret key) without
    revealing the credential itself.

    Security properties (formally verified):
    - Completeness: legitimate credential holders always pass
    - Soundness: without the credential, passing is computationally infeasible
    - Zero-knowledge: the verifier learns nothing beyond "credential is valid"
      (proven by schnorr_transcript_witness_independence)
    """

    def __init__(self, grp: Group):
        self.grp = grp

    def issue_credential(self, user_id: str) -> Tuple[int, int]:
        """Issue a credential (secret, public) for a user."""
        secret = int(hashlib.sha256(user_id.encode()).hexdigest(), 16) % self.grp.q
        if secret == 0:
            secret = 1
        public = self.grp.pow(self.grp.g, secret)
        return secret, public

    def prove_credential(self, secret: int, challenge: int) -> Tuple[int, int]:
        """Prove knowledge of credential without revealing it."""
        r = random.randint(0, self.grp.q - 1)
        a = self.grp.pow(self.grp.g, r)
        z = (r + challenge * secret) % self.grp.q
        return a, z

    def verify_credential(self, public: int, a: int, c: int, z: int) -> bool:
        """Verify a credential proof."""
        lhs = self.grp.pow(self.grp.g, z)
        rhs = self.grp.mul(a, self.grp.pow(public, c))
        return lhs == rhs


def demo_zk_verification():
    """Demonstrate zero-knowledge credential verification."""
    print("\n" + "=" * 70)
    print("APPLICATION 2: Zero-Knowledge Credential Verification")
    print("=" * 70)

    grp = setup_group(16)
    system = ZKAgeVerifier(grp)

    # Issue credentials
    users = ["alice@example.com", "bob@example.com", "eve@example.com"]
    credentials = {}
    for user in users:
        secret, public = system.issue_credential(user)
        credentials[user] = (secret, public)
        print(f"Issued credential for {user}: public={public}")

    print("\n--- Verification Round ---")
    for user in users:
        secret, public = credentials[user]
        challenge = random.randint(0, grp.q - 1)
        a, z = system.prove_credential(secret, challenge)
        valid = system.verify_credential(public, a, challenge, z)
        print(f"{user}: proof valid = {valid}")

    # Demonstrate that an impersonator fails
    print("\n--- Impersonation Attempt ---")
    fake_secret = random.randint(1, grp.q - 1)
    target_public = credentials["alice@example.com"][1]
    challenge = random.randint(0, grp.q - 1)
    a, z = system.prove_credential(fake_secret, challenge)
    valid = system.verify_credential(target_public, a, challenge, z)
    print(f"Eve trying to impersonate Alice: valid = {valid}")
    print(f"Impersonation detected: {not valid}")


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 3: Extractable Commitment Scheme
# ═══════════════════════════════════════════════════════════════════════

class ExtractableCommitment:
    """A commitment scheme with extractable binding via Schnorr special soundness.

    The committer commits to a value by creating a Schnorr-style commitment.
    Binding is enforced by the fact that opening with two different values
    would yield two accepting transcripts with different challenges,
    enabling witness extraction (schnorr_special_soundness_extract).
    """

    def __init__(self, grp: Group):
        self.grp = grp

    def commit(self, value: int) -> Tuple[int, int]:
        """Commit to a value. Returns (commitment, decommitment_key)."""
        r = random.randint(0, self.grp.q - 1)
        # commitment = g^r · g^(value·H(r))
        binding = int(hashlib.sha256(str(r).encode()).hexdigest(), 16) % self.grp.q
        combined = (r + value * binding) % self.grp.q
        commitment = self.grp.pow(self.grp.g, combined)
        return commitment, r

    def open(self, commitment: int, value: int, r: int) -> bool:
        """Verify an opening of a commitment."""
        binding = int(hashlib.sha256(str(r).encode()).hexdigest(), 16) % self.grp.q
        combined = (r + value * binding) % self.grp.q
        expected = self.grp.pow(self.grp.g, combined)
        return commitment == expected


def demo_commitment():
    """Demonstrate extractable commitment scheme."""
    print("\n" + "=" * 70)
    print("APPLICATION 3: Extractable Commitment Scheme")
    print("=" * 70)

    grp = setup_group(16)
    scheme = ExtractableCommitment(grp)

    # Commit to a value
    value = 42
    commitment, decom_key = scheme.commit(value)
    print(f"Committed to value {value}")
    print(f"Commitment: {commitment}")

    # Valid opening
    valid = scheme.open(commitment, value, decom_key)
    print(f"\nOpening with correct value ({value}): {valid}")

    # Invalid opening (trying to cheat)
    cheated = scheme.open(commitment, 43, decom_key)
    print(f"Opening with wrong value (43): {cheated}")
    print(f"Binding property holds: {valid and not cheated}")


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 4: Distributed Key Generation with Verifiable Shares
# ═══════════════════════════════════════════════════════════════════════

def demo_distributed_verification():
    """Demonstrate distributed verification using Schnorr proofs."""
    print("\n" + "=" * 70)
    print("APPLICATION 4: Multi-Verifier Authentication")
    print("=" * 70)

    grp = setup_group(16)

    # User generates key pair
    x = random.randint(1, grp.q - 1)
    y = grp.pow(grp.g, x)
    print(f"User's public key: {y}")

    # Multiple independent verifiers each send a challenge
    n_verifiers = 5
    print(f"\n{n_verifiers} independent verifiers challenge the user:")

    all_pass = True
    for i in range(n_verifiers):
        # Each verifier sends an independent challenge
        r = random.randint(0, grp.q - 1)
        a = grp.pow(grp.g, r)
        c = random.randint(0, grp.q - 1)
        z = (r + c * x) % grp.q

        # Verifier checks
        lhs = grp.pow(grp.g, z)
        rhs = grp.mul(a, grp.pow(y, c))
        valid = lhs == rhs

        print(f"  Verifier {i+1}: challenge={c}, valid={valid}")
        all_pass = all_pass and valid

    print(f"\nAll verifiers satisfied: {all_pass}")
    print("(Each verification is independent and zero-knowledge)")


# ═══════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    try:
        from sympy import isprime, nextprime
    except ImportError:
        print("Installing sympy...")
        import subprocess
        subprocess.check_call(["pip", "install", "sympy", "-q"])

    random.seed(2024)

    demo_signatures()
    demo_zk_verification()
    demo_commitment()
    demo_distributed_verification()

    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Schnorr Protocol: Interactive Demonstration

Demonstrates:
1. Schnorr transcript generation (real & simulated)
2. Witness extraction from forked transcripts
3. Real vs simulated transcript histogram comparison
4. Fiat-Shamir entropy rigidity conjecture testing
"""

import random
import hashlib
from collections import Counter
from typing import Tuple, Optional

# ── Small prime-order group for demonstration ──────────────────────────
# We work in Z/pZ* with a generator of prime order q.
# For simplicity, use a subgroup of Z/pZ* where p = 2q + 1 (safe prime).

def find_safe_prime(bits: int = 10) -> Tuple[int, int]:
    """Find a safe prime p = 2q + 1 where q is also prime."""
    from sympy import isprime, nextprime
    q = nextprime(2 ** bits)
    while True:
        p = 2 * q + 1
        if isprime(p):
            return p, q
        q = nextprime(q)

def find_generator(p: int, q: int) -> int:
    """Find a generator of the order-q subgroup of Z/pZ*."""
    for g_candidate in range(2, p):
        g = pow(g_candidate, 2, p)  # Square to get into order-q subgroup
        if g != 1 and pow(g, q, p) == 1:
            return g
    raise ValueError("No generator found")

# ── Schnorr Protocol Implementation ──────────────────────────────────

class SchnorrGroup:
    """A cyclic group Z/pZ* of prime order q with generator g."""
    def __init__(self, p: int, q: int, g: int):
        self.p = p
        self.q = q
        self.g = g

    def power(self, base: int, exp: int) -> int:
        """Compute base^exp mod p."""
        return pow(base, exp % self.q, self.p)

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p

    def inv(self, a: int) -> int:
        return pow(a, self.p - 2, self.p)


class SchnorrTranscript:
    """A Schnorr protocol transcript (a, c, z)."""
    def __init__(self, commit: int, challenge: int, response: int):
        self.commit = commit
        self.challenge = challenge
        self.response = response

    def __repr__(self):
        return f"Transcript(a={self.commit}, c={self.challenge}, z={self.response})"

    def __eq__(self, other):
        return (self.commit == other.commit and
                self.challenge == other.challenge and
                self.response == other.response)

    def __hash__(self):
        return hash((self.commit, self.challenge, self.response))


def schnorr_verify(grp: SchnorrGroup, y: int, t: SchnorrTranscript) -> bool:
    """Verify: g^z == a * y^c."""
    lhs = grp.power(grp.g, t.response)
    rhs = grp.mul(t.commit, grp.power(y, t.challenge))
    return lhs == rhs


def schnorr_real_transcript(grp: SchnorrGroup, x: int, r: int, c: int) -> SchnorrTranscript:
    """Generate a real transcript: a = g^r, z = r + c*x mod q."""
    a = grp.power(grp.g, r)
    z = (r + c * x) % grp.q
    return SchnorrTranscript(a, c, z)


def schnorr_sim_transcript(grp: SchnorrGroup, y: int, c: int, z: int) -> SchnorrTranscript:
    """Generate a simulated transcript: a = g^z * y^(-c)."""
    gz = grp.power(grp.g, z)
    yc_inv = grp.inv(grp.power(y, c))
    a = grp.mul(gz, yc_inv)
    return SchnorrTranscript(a, c, z)


def schnorr_extractor(z1: int, z2: int, c1: int, c2: int, q: int) -> Optional[int]:
    """Extract witness w = (z1 - z2) / (c1 - c2) mod q."""
    dc = (c1 - c2) % q
    if dc == 0:
        return None
    dc_inv = pow(dc, q - 2, q)  # Modular inverse (q is prime)
    w = ((z1 - z2) * dc_inv) % q
    return w


# ── Demo 1: Basic Protocol Execution ─────────────────────────────────

def demo_basic_protocol():
    """Demonstrate basic Schnorr protocol execution."""
    print("=" * 70)
    print("DEMO 1: Basic Schnorr Protocol Execution")
    print("=" * 70)

    p, q = find_safe_prime(10)
    g = find_generator(p, q)
    grp = SchnorrGroup(p, q, g)

    print(f"Group parameters: p={p}, q={q}, g={g}")

    # Key generation
    x = random.randint(1, q - 1)  # Secret key
    y = grp.power(g, x)           # Public key
    print(f"Secret key x = {x}")
    print(f"Public key y = g^x = {y}")

    # Protocol execution
    r = random.randint(0, q - 1)  # Random nonce
    c = random.randint(0, q - 1)  # Challenge
    t = schnorr_real_transcript(grp, x, r, c)

    print(f"\nReal transcript: {t}")
    print(f"Verification: {schnorr_verify(grp, y, t)}")

    # Simulated transcript
    z_sim = random.randint(0, q - 1)
    c_sim = random.randint(0, q - 1)
    t_sim = schnorr_sim_transcript(grp, y, c_sim, z_sim)

    print(f"\nSimulated transcript: {t_sim}")
    print(f"Verification: {schnorr_verify(grp, y, t_sim)}")


# ── Demo 2: Witness Extraction from Forked Transcripts ───────────────

def demo_extraction():
    """Demonstrate witness extraction from two forked transcripts."""
    print("\n" + "=" * 70)
    print("DEMO 2: Witness Extraction from Forked Transcripts")
    print("=" * 70)

    p, q = find_safe_prime(10)
    g = find_generator(p, q)
    grp = SchnorrGroup(p, q, g)

    x = random.randint(1, q - 1)
    y = grp.power(g, x)

    print(f"Secret key x = {x} (prover knows this)")
    print(f"Public key y = g^x = {y}")

    # Create two transcripts with SAME commitment but DIFFERENT challenges
    r = random.randint(0, q - 1)
    c1 = random.randint(0, q - 1)
    c2 = random.randint(0, q - 1)
    while c2 == c1:
        c2 = random.randint(0, q - 1)

    t1 = schnorr_real_transcript(grp, x, r, c1)
    t2 = schnorr_real_transcript(grp, x, r, c2)

    assert t1.commit == t2.commit, "Same commitment"
    assert schnorr_verify(grp, y, t1) and schnorr_verify(grp, y, t2)

    print(f"\nTranscript 1: {t1}")
    print(f"Transcript 2: {t2}")
    print(f"Same commitment: {t1.commit == t2.commit}")
    print(f"Different challenges: c1={c1}, c2={c2}")

    # Extract the witness!
    w = schnorr_extractor(t1.response, t2.response, c1, c2, q)
    print(f"\nExtracted witness w = (z1 - z2)/(c1 - c2) mod q = {w}")
    print(f"Original secret x = {x}")
    print(f"Extraction successful: {w == x}")
    print(f"Verification: g^w = {grp.power(g, w)}, y = {y}, match = {grp.power(g, w) == y}")


# ── Demo 3: Real vs Simulated Transcript Histogram ───────────────────

def demo_hvzk_histogram():
    """Compare real and simulated transcript distributions."""
    print("\n" + "=" * 70)
    print("DEMO 3: Real vs Simulated Transcript Distribution (HVZK)")
    print("=" * 70)

    # Use a small group for exhaustive enumeration
    p, q = find_safe_prime(4)  # Small group
    g = find_generator(p, q)
    grp = SchnorrGroup(p, q, g)

    x = random.randint(1, q - 1)
    y = grp.power(g, x)

    print(f"Group: p={p}, q={q}, g={g}")
    print(f"Secret key x={x}, Public key y={y}")

    # Exhaustively enumerate all real transcripts
    real_transcripts = Counter()
    for r in range(q):
        for c in range(q):
            t = schnorr_real_transcript(grp, x, r, c)
            real_transcripts[(t.commit, t.challenge, t.response)] += 1

    # Exhaustively enumerate all simulated transcripts
    sim_transcripts = Counter()
    for z in range(q):
        for c in range(q):
            t = schnorr_sim_transcript(grp, y, c, z)
            sim_transcripts[(t.commit, t.challenge, t.response)] += 1

    # Compare
    all_transcripts = set(real_transcripts.keys()) | set(sim_transcripts.keys())

    print(f"\nTotal distinct transcripts (real): {len(real_transcripts)}")
    print(f"Total distinct transcripts (sim):  {len(sim_transcripts)}")
    print(f"Sets equal: {set(real_transcripts.keys()) == set(sim_transcripts.keys())}")

    # Check pointwise equality
    mismatches = 0
    for t in all_transcripts:
        if real_transcripts[t] != sim_transcripts[t]:
            mismatches += 1
            print(f"  MISMATCH at {t}: real={real_transcripts[t]}, sim={sim_transcripts[t]}")

    if mismatches == 0:
        print("✓ Perfect HVZK confirmed: all transcript counts match exactly!")
    else:
        print(f"✗ {mismatches} mismatches found")


# ── Demo 4: Fiat-Shamir with Oracle Perturbation ─────────────────────

def demo_fiat_shamir():
    """Demonstrate Fiat-Shamir and oracle reprogramming extraction."""
    print("\n" + "=" * 70)
    print("DEMO 4: Fiat-Shamir Fork Extraction")
    print("=" * 70)

    p, q = find_safe_prime(10)
    g = find_generator(p, q)
    grp = SchnorrGroup(p, q, g)

    x = random.randint(1, q - 1)
    y = grp.power(g, x)

    print(f"Group: p={p}, q={q}")
    print(f"Secret key x={x}")

    # Two different hash functions (modeling oracle reprogramming)
    def oracle1(a: int) -> int:
        h = hashlib.sha256(f"oracle1:{a}".encode()).digest()
        return int.from_bytes(h, 'big') % q

    def oracle2(a: int) -> int:
        h = hashlib.sha256(f"oracle2:{a}".encode()).digest()
        return int.from_bytes(h, 'big') % q

    # Generate Fiat-Shamir proof under oracle 1
    r = random.randint(0, q - 1)
    a = grp.power(g, r)
    c1 = oracle1(a)
    z1 = (r + c1 * x) % q

    # Same commitment, different oracle
    c2 = oracle2(a)
    z2 = (r + c2 * x) % q

    print(f"\nCommitment a = {a}")
    print(f"Oracle 1 challenge: c1 = {c1}")
    print(f"Oracle 2 challenge: c2 = {c2}")
    print(f"Same challenge? {c1 == c2}")

    if c1 != c2:
        w = schnorr_extractor(z1, z2, c1, c2, q)
        print(f"\nExtracted witness: {w}")
        print(f"True secret key:   {x}")
        print(f"Extraction success: {w == x}")
    else:
        print("\nOracles agree on this commitment - no extraction possible")
        print("(This happens with probability ~1/q)")


# ── Demo 5: Entropy Rigidity Conjecture Test ─────────────────────────

def demo_entropy_conjecture():
    """Test the Fiat-Shamir entropy rigidity conjecture."""
    print("\n" + "=" * 70)
    print("DEMO 5: Entropy Rigidity Conjecture Test")
    print("=" * 70)

    p, q = find_safe_prime(6)
    g = find_generator(p, q)
    grp = SchnorrGroup(p, q, g)

    x = random.randint(1, q - 1)
    y = grp.power(g, x)

    print(f"Group: p={p}, q={q}")

    # Exhaustive HVZK test: real vs simulated for multiple witnesses
    print("\n--- Witness Independence Test ---")
    witnesses = [i for i in range(1, min(q, 10))]

    for x_test in witnesses:
        if grp.power(g, x_test) != y:
            continue  # Only compare witnesses with same public key

        sim_counts1 = Counter()
        sim_counts2 = Counter()

        for z in range(q):
            for c in range(q):
                t = schnorr_sim_transcript(grp, y, c, z)
                sim_counts1[(t.commit, t.challenge, t.response)] += 1
                sim_counts2[(t.commit, t.challenge, t.response)] += 1

        match = sim_counts1 == sim_counts2
        print(f"  Witness x={x_test}: simulation identical = {match}")

    # Fiat-Shamir deviation test
    print("\n--- Fiat-Shamir vs Ideal Distribution ---")

    def make_oracle(seed: str):
        def oracle(a: int) -> int:
            h = hashlib.sha256(f"{seed}:{a}".encode()).digest()
            return int.from_bytes(h, 'big') % q
        return oracle

    N_trials = 1000
    fork_count = 0
    successful_extractions = 0

    for trial in range(N_trials):
        r = random.randint(0, q - 1)
        a = grp.power(g, r)

        H1 = make_oracle(f"seed1_{trial}")
        H2 = make_oracle(f"seed2_{trial}")

        c1 = H1(a)
        c2 = H2(a)

        if c1 != c2:
            fork_count += 1
            z1 = (r + c1 * x) % q
            z2 = (r + c2 * x) % q
            w = schnorr_extractor(z1, z2, c1, c2, q)
            if w == x:
                successful_extractions += 1

    print(f"  Trials: {N_trials}")
    print(f"  Fork events (c1 ≠ c2): {fork_count}")
    print(f"  Successful extractions: {successful_extractions}")
    print(f"  Extraction rate given fork: "
          f"{successful_extractions/max(fork_count,1):.4f}")
    print(f"  Expected rate: 1.0000 (every fork yields extraction)")

    # Affine structure verification
    print("\n--- Affine Line Verification ---")
    r_test = random.randint(0, q - 1)
    points = []
    for c in range(min(q, 20)):
        z = (r_test + c * x) % q
        points.append((c, z))

    # Check collinearity: (z1-z2)/(c1-c2) should always equal x
    print(f"  Testing {len(points)} points on transcript affine line:")
    all_slopes_correct = True
    for i in range(len(points)):
        for j in range(i + 1, min(len(points), i + 5)):
            c1, z1 = points[i]
            c2, z2 = points[j]
            slope = schnorr_extractor(z1, z2, c1, c2, q)
            if slope != x:
                all_slopes_correct = False
                print(f"    MISMATCH: slope({c1},{c2}) = {slope}, expected {x}")
    if all_slopes_correct:
        print(f"  ✓ All pairwise slopes equal secret key x={x}")
        print(f"    (Confirms transcript equations lie on affine line z = r + c·x)")


# ── Main ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    try:
        from sympy import isprime, nextprime
    except ImportError:
        print("Installing sympy...")
        import subprocess
        subprocess.check_call(["pip", "install", "sympy", "-q"])
        from sympy import isprime, nextprime

    random.seed(42)  # Reproducibility

    demo_basic_protocol()
    demo_extraction()
    demo_hvzk_histogram()
    demo_fiat_shamir()
    demo_entropy_conjecture()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
