"""
Algorithms for Logistic Map Cryptography

Implements the cryptographic primitives derived from the logistic map
f(x) = 4x(1-x) at r=4, including:
  - Logistic cipher (keystream generation)
  - Orbit-based hash function
  - Tropical approximation cipher
  - Periodic orbit analysis

Complexity Analysis:
  - Keystream generation: O(n) time, O(1) space per symbol
  - Hash function: O(n) time, O(1) space
  - Polynomial degree growth: 2^n (exponential hardness)
"""
import math
from typing import List, Tuple, Optional


def logistic_map(x: float) -> float:
    """The logistic map at r=4: f(x) = 4x(1-x).

    Time: O(1), Space: O(1)
    """
    return 4.0 * x * (1.0 - x)


def logistic_iterate(n: int, x: float) -> float:
    """Compute the n-th iterate f^n(x).

    Time: O(n), Space: O(1)
    """
    for _ in range(n):
        x = logistic_map(x)
    return x


def logistic_orbit(x: float, length: int) -> List[float]:
    """Generate the orbit {x, f(x), f^2(x), ...} of length `length`.

    Time: O(length), Space: O(length)
    """
    orbit = [x]
    for _ in range(length - 1):
        x = logistic_map(x)
        orbit.append(x)
    return orbit


class LogisticCipher:
    """A stream cipher based on the logistic map.

    The key is (seed, warmup) where:
      - seed ∈ (0,1) is the initial condition
      - warmup is the number of transient iterations to skip

    Security is based on the exponential degree growth of iterate
    polynomials: inverting f^n requires solving a degree-2^n polynomial.

    Time complexity: O(warmup + n) for n keystream bytes
    Space complexity: O(1)
    """

    def __init__(self, seed: float, warmup: int = 100):
        """Initialize with seed ∈ (0,1) and warmup iterations.

        Args:
            seed: Initial condition, must satisfy 0 < seed < 1
            warmup: Number of transient iterations to discard
        """
        assert 0 < seed < 1, "Seed must be in (0,1)"
        assert warmup >= 0, "Warmup must be non-negative"
        self.seed = seed
        self.warmup = warmup
        self._state = seed
        # Skip transient iterations
        for _ in range(warmup):
            self._state = logistic_map(self._state)

    def next_float(self) -> float:
        """Generate next keystream value in [0,1].

        Time: O(1)
        """
        self._state = logistic_map(self._state)
        return self._state

    def next_byte(self) -> int:
        """Generate next keystream byte (0-255).

        Maps the continuous [0,1] output to discrete bytes.
        Time: O(1)
        """
        return int(self.next_float() * 256) % 256

    def encrypt(self, plaintext: bytes) -> bytes:
        """Encrypt plaintext by XOR with keystream.

        Time: O(len(plaintext)), Space: O(len(plaintext))
        """
        return bytes(b ^ self.next_byte() for b in plaintext)

    def decrypt(self, ciphertext: bytes) -> bytes:
        """Decrypt = encrypt (XOR is its own inverse).

        Time: O(len(ciphertext)), Space: O(len(ciphertext))
        """
        return self.encrypt(ciphertext)


class LogisticHash:
    """A hash function based on logistic map orbit mixing.

    Maps arbitrary byte strings to fixed-length digests by:
    1. Converting input bytes to a seed in (0,1)
    2. Running the logistic map for input-dependent iterations
    3. Extracting hash bits from the final orbit segment

    Preimage resistance is based on the superpolynomial hardness:
    finding x such that f^n(x) = target requires solving degree-2^n.

    Time: O(n * block_size), Space: O(digest_size)
    """

    def __init__(self, digest_size: int = 16):
        self.digest_size = digest_size

    def hash(self, data: bytes) -> bytes:
        """Compute hash of data.

        Args:
            data: Input bytes to hash

        Returns:
            Hash digest of length self.digest_size
        """
        # Initialize state from data
        state = 0.5  # start at critical point
        for i, byte in enumerate(data):
            # Mix each byte into the state
            perturbation = (byte + 1) / 258.0  # map to (0,1)
            state = logistic_map(state * 0.5 + perturbation * 0.5)
            # Additional mixing iterations
            for _ in range(3):
                state = logistic_map(state)

        # Generate digest
        digest = []
        for _ in range(self.digest_size):
            state = logistic_map(state)
            digest.append(int(state * 256) % 256)
        return bytes(digest)


def tropical_tent_map(x: float) -> float:
    """The tropical tent map: T(x) = 2*min(x, 1-x).

    Piecewise-linear approximation to the logistic map.
    Maximum approximation error: 1/4 (achieved at x = (2±√2)/4).

    Time: O(1), Space: O(1)
    """
    return 2 * min(x, 1 - x)


def tropical_cipher_orbit(x: float, length: int) -> List[float]:
    """Generate orbit under the tropical tent map.

    The tropical tent map is computationally simpler (no multiplication)
    and maintains the same topological structure as the logistic map.

    Time: O(length), Space: O(length)
    """
    orbit = [x]
    for _ in range(length - 1):
        x = tropical_tent_map(x)
        orbit.append(x)
    return orbit


def chebyshev_conjugate_orbit(theta: float, length: int) -> List[float]:
    """Generate the semiconjugate orbit via sin²(2ⁿθ).

    Uses the Chebyshev semiconjugacy: f^n(sin²θ) = sin²(2ⁿθ).
    This is mathematically exact but numerically unstable for large n.

    Time: O(length), Space: O(length)
    """
    return [math.sin(2**n * theta)**2 for n in range(length)]


def find_period(x: float, max_iter: int = 1000, tol: float = 1e-10) -> Optional[Tuple[int, int]]:
    """Find the eventual period of an orbit.

    Returns (preperiod, period) if found, None otherwise.
    Uses Floyd's cycle detection algorithm.

    Time: O(max_iter), Space: O(1)
    """
    # Floyd's tortoise and hare
    tortoise = logistic_map(x)
    hare = logistic_map(logistic_map(x))
    steps = 0
    while abs(tortoise - hare) > tol and steps < max_iter:
        tortoise = logistic_map(tortoise)
        hare = logistic_map(logistic_map(hare))
        steps += 1
    if steps >= max_iter:
        return None
    # Find preperiod
    mu = 0
    tortoise = x
    while abs(tortoise - hare) > tol:
        tortoise = logistic_map(tortoise)
        hare = logistic_map(hare)
        mu += 1
    # Find period
    lam = 1
    hare = logistic_map(tortoise)
    while abs(tortoise - hare) > tol:
        hare = logistic_map(hare)
        lam += 1
    return (mu, lam)


def orbit_derivative_product(x: float, n: int) -> float:
    """Compute the product of derivatives along an orbit of length n.

    Returns ∏_{k=0}^{n-1} f'(f^k(x)) where f'(x) = 4-8x.

    At x = 3/4 (unstable fixed point), this equals (-2)^n,
    giving |product| = 2^n — exponential sensitivity.

    Time: O(n), Space: O(1)
    """
    product = 1.0
    current = x
    for _ in range(n):
        deriv = 4.0 - 8.0 * current
        product *= deriv
        current = logistic_map(current)
    return product


def lyapunov_exponent(x: float, n: int = 10000) -> float:
    """Estimate the Lyapunov exponent of the logistic map at r=4.

    Computes (1/n) ∑_{k=0}^{n-1} log|f'(f^k(x))|.
    For the arcsine measure, the theoretical value is log(2) ≈ 0.6931.

    Time: O(n), Space: O(1)
    """
    total = 0.0
    current = x
    for _ in range(n):
        deriv = abs(4.0 - 8.0 * current)
        if deriv > 0:
            total += math.log(deriv)
        current = logistic_map(current)
    return total / n


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("=== Logistic Cipher Demo ===")
    cipher1 = LogisticCipher(seed=0.123456789, warmup=100)
    cipher2 = LogisticCipher(seed=0.123456789, warmup=100)

    message = b"Hello, Chaos!"
    encrypted = cipher1.encrypt(message)
    decrypted = cipher2.decrypt(encrypted)

    print(f"Message:   {message}")
    print(f"Encrypted: {encrypted.hex()}")
    print(f"Decrypted: {decrypted}")
    assert message == decrypted, "Decryption failed!"

    print("\n=== Logistic Hash Demo ===")
    hasher = LogisticHash(digest_size=16)
    h1 = hasher.hash(b"test message")
    h2 = hasher.hash(b"test messag!")
    print(f"Hash('test message'): {h1.hex()}")
    print(f"Hash('test messag!'): {h2.hex()}")
    print(f"Avalanche: {sum(bin(a^b).count('1') for a,b in zip(h1,h2))} bit changes out of {8*len(h1)}")

    print("\n=== Lyapunov Exponent Estimation ===")
    lexp = lyapunov_exponent(0.1, n=100000)
    print(f"Estimated: {lexp:.6f}")
    print(f"Theoretical (log 2): {math.log(2):.6f}")
    print(f"Error: {abs(lexp - math.log(2)):.6f}")

    print("\n=== Period Detection ===")
    # sin²(π/3) = 3/4 is a fixed point
    result = find_period(3/4)
    print(f"Period of 3/4: {result}")
    # sin²(π/4) = 1/2 → 1 → 0 → 0 (preperiod 2, period 1)
    result = find_period(0.5)
    print(f"Period of 1/2: {result}")
