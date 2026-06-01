"""
Algorithms for Isogeny-Based Cryptography: CSI-FiSh

Type-hinted implementations of the core algorithms formalized in Lean.
"""
from typing import List, Tuple, Callable, TypeVar, Generic
from dataclasses import dataclass
import hashlib
import secrets

T = TypeVar('T')
G = TypeVar('G')


@dataclass
class GroupAction(Generic[G, T]):
    """Abstract group action: a group G acting on a set X."""
    act: Callable[[G, T], T]
    identity: G
    multiply: Callable[[G, G], G]
    inverse: Callable[[G], G]


class CyclicGroupAction:
    """Concrete group action: Z/nZ acting on Z/nZ by addition.
    Models the class group action in a simplified setting."""

    def __init__(self, n: int):
        self.n = n

    def act(self, g: int, x: int) -> int:
        return (g + x) % self.n

    def multiply(self, g: int, h: int) -> int:
        return (g + h) % self.n

    def inverse(self, g: int) -> int:
        return (-g) % self.n

    def connector(self, x: int, y: int) -> int:
        """Compute the unique group element mapping x to y (GAIP)."""
        return (y - x) % self.n


class CSIDHSimulator:
    """Simulates CSIDH key exchange over a cyclic group (for demonstration)."""

    def __init__(self, n: int):
        self.ga = CyclicGroupAction(n)
        self.n = n

    def keygen(self) -> Tuple[int, int]:
        """Generate a secret/public key pair."""
        secret = secrets.randbelow(self.n)
        base = 0  # Fixed base point
        public = self.ga.act(secret, base)
        return secret, public

    def shared_secret(self, my_secret: int, their_public: int) -> int:
        """Compute shared secret from own secret and partner's public key."""
        return self.ga.act(my_secret, their_public)

    def verify_agreement(self, alice_secret: int, bob_secret: int) -> bool:
        """Verify that Alice and Bob compute the same shared secret."""
        base = 0
        alice_pub = self.ga.act(alice_secret, base)
        bob_pub = self.ga.act(bob_secret, base)

        alice_shared = self.ga.act(alice_secret, bob_pub)
        bob_shared = self.ga.act(bob_secret, alice_pub)

        return alice_shared == bob_shared


class CSIFiShIdentification:
    """CSI-FiSh identification scheme (sigma protocol)."""

    def __init__(self, n: int):
        self.ga = CyclicGroupAction(n)
        self.n = n
        self.base = 0

    def commit(self, secret: int) -> Tuple[int, int]:
        """Prover commits: choose random r, compute R = r · x₀."""
        r = secrets.randbelow(self.n)
        R = self.ga.act(r, self.base)
        return r, R

    def respond(self, r: int, secret: int, challenge: bool) -> int:
        """Prover responds to challenge."""
        if challenge:  # challenge = 1
            return (r - secret) % self.n  # z = r · s⁻¹
        else:  # challenge = 0
            return r  # z = r

    def verify(self, pk: int, R: int, challenge: bool, response: int) -> bool:
        """Verifier checks the response."""
        if challenge:
            return self.ga.act(response, pk) == R
        else:
            return self.ga.act(response, self.base) == R

    def extract_secret(
        self, z0: int, z1: int
    ) -> int:
        """Special soundness: extract secret from two transcripts."""
        return (z0 - z1) % self.n


class CSIFiShSignature:
    """CSI-FiSh signature scheme via Fiat-Shamir transform."""

    def __init__(self, n: int, num_rounds: int = 128):
        self.ident = CSIFiShIdentification(n)
        self.n = n
        self.num_rounds = num_rounds

    def _hash_to_challenges(self, message: bytes, commitments: List[int]) -> List[bool]:
        """Hash message and commitments to challenge bits."""
        data = message + b'|' + b','.join(str(c).encode() for c in commitments)
        h = hashlib.sha256(data).digest()
        bits = []
        for i in range(self.num_rounds):
            byte_idx = i // 8
            bit_idx = i % 8
            if byte_idx < len(h):
                bits.append(bool((h[byte_idx] >> bit_idx) & 1))
            else:
                bits.append(False)
        return bits

    def sign(
        self, secret: int, message: bytes
    ) -> Tuple[List[int], List[bool], List[int]]:
        """Sign a message."""
        # Generate commitments
        randomness = []
        commitments = []
        for _ in range(self.num_rounds):
            r, R = self.ident.commit(secret)
            randomness.append(r)
            commitments.append(R)

        # Compute challenges via Fiat-Shamir
        challenges = self._hash_to_challenges(message, commitments)

        # Compute responses
        responses = []
        for i in range(self.num_rounds):
            z = self.ident.respond(randomness[i], secret, challenges[i])
            responses.append(z)

        return commitments, challenges, responses

    def verify(
        self,
        pk: int,
        message: bytes,
        signature: Tuple[List[int], List[bool], List[int]],
    ) -> bool:
        """Verify a signature."""
        commitments, challenges, responses = signature

        # Recompute challenges
        expected_challenges = self._hash_to_challenges(message, commitments)
        if challenges != expected_challenges:
            return False

        # Verify each round
        for i in range(self.num_rounds):
            if not self.ident.verify(pk, commitments[i], challenges[i], responses[i]):
                return False

        return True


def keyspace_size(num_primes: int, bound: int) -> int:
    """Compute the CSIDH key space size: (2B+1)^n."""
    return (2 * bound + 1) ** num_primes


def cayley_diameter(n: int) -> int:
    """Compute the Cayley graph diameter for Z/nZ with generators {+1, -1}."""
    return n // 2


def verify_cayley_conjecture(n: int) -> bool:
    """Verify the Cayley diameter conjecture for a specific n."""
    d = cayley_diameter(n)
    for a in range(n):
        found = False
        for k in range(d + 1):
            if a == k % n or a == (-k) % n:
                found = True
                break
        if not found:
            return False
    return True


def multi_party_csidh(secrets: List[int], n: int) -> int:
    """Multi-party CSIDH: compute shared key from all secrets."""
    ga = CyclicGroupAction(n)
    result = 0  # base point
    total = sum(secrets) % n
    return ga.act(total, 0)


if __name__ == "__main__":
    # Quick test
    sim = CSIDHSimulator(997)
    assert sim.verify_agreement(42, 73)
    print("CSIDH agreement: OK")

    # CSI-FiSh signature
    sig_scheme = CSIFiShSignature(997, num_rounds=16)
    secret = 42
    pk = CyclicGroupAction(997).act(secret, 0)
    msg = b"Hello, post-quantum world!"
    signature = sig_scheme.sign(secret, msg)
    assert sig_scheme.verify(pk, msg, signature)
    print("CSI-FiSh signature: OK")

    # Cayley conjecture
    for p in [3, 5, 7, 11, 13, 17, 19, 23]:
        assert verify_cayley_conjecture(p), f"Conjecture failed for n={p}"
    print("Cayley diameter conjecture: verified for small primes")
