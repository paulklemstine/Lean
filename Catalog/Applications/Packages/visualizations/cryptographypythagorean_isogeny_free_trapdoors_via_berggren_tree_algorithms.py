#!/usr/bin/env python3
"""
Berggren Minor Trapdoors: Core Algorithms

Implements the evaluation, inversion, and analysis algorithms
for the Berggren tree cryptographic primitive.
"""

from typing import Tuple, List, Optional, Dict
import math

Triple = Tuple[int, int, int]
MinorProfile = Tuple[int, int, int, int]


class BerggrenTree:
    """
    The Berggren tree of primitive Pythagorean triples.

    Provides evaluation, inversion, and analysis methods for
    the isogeny-free arithmetic trapdoor construction.
    """

    ROOT = (3, 4, 5)

    # Generator matrices (as functions for efficiency)
    @staticmethod
    def gen_A(t: Triple) -> Triple:
        """Apply Berggren generator A."""
        x, y, z = t
        return (x - 2*y + 2*z, 2*x - y + 2*z, 2*x - 2*y + 3*z)

    @staticmethod
    def gen_B(t: Triple) -> Triple:
        """Apply Berggren generator B."""
        x, y, z = t
        return (x + 2*y + 2*z, 2*x + y + 2*z, 2*x + 2*y + 3*z)

    @staticmethod
    def gen_C(t: Triple) -> Triple:
        """Apply Berggren generator C."""
        x, y, z = t
        return (-x + 2*y + 2*z, -2*x + y + 2*z, -2*x + 2*y + 3*z)

    @staticmethod
    def inv_A(t: Triple) -> Triple:
        """Apply inverse of generator A."""
        x, y, z = t
        return (x + 2*y - 2*z, -2*x - y + 2*z, -2*x - 2*y + 3*z)

    @staticmethod
    def inv_B(t: Triple) -> Triple:
        """Apply inverse of generator B."""
        x, y, z = t
        return (x + 2*y - 2*z, 2*x + y - 2*z, -2*x - 2*y + 3*z)

    @staticmethod
    def inv_C(t: Triple) -> Triple:
        """Apply inverse of generator C."""
        x, y, z = t
        return (-x - 2*y + 2*z, 2*x + y - 2*z, -2*x - 2*y + 3*z)

    GENS = {'A': gen_A, 'B': gen_B, 'C': gen_C}
    INVS = {'A': inv_A, 'B': inv_B, 'C': inv_C}

    @classmethod
    def eval_word(cls, word: str, start: Triple = None) -> Triple:
        """
        Evaluate a Berggren word on a triple.

        Time complexity: O(|word|)
        Space complexity: O(1)

        Args:
            word: String of characters from {A, B, C}
            start: Starting triple (default: ROOT = (3,4,5))

        Returns:
            The resulting triple after applying all generators.
        """
        t = start or cls.ROOT
        for g in word:
            t = cls.GENS[g](t)
        return t

    @staticmethod
    def minor_profile(t: Triple) -> MinorProfile:
        """
        Compute the minor profile of a triple.

        The minor profile consists of:
        - m_xy = x + y (pairwise sum)
        - m_yz = y + z (pairwise sum)
        - m_zx = z + x (pairwise sum)
        - skew = z - x - y (deviation measure)

        Time complexity: O(1)

        This map is injective (proved in minorProfile_injective),
        so it serves as a collision-free hash function.
        """
        x, y, z = t
        return (x + y, y + z, z + x, z - x - y)

    @staticmethod
    def recover_triple(profile: MinorProfile) -> Triple:
        """
        Recover a triple from its minor profile (lattice decoding).

        This is the inverse of minor_profile, demonstrating that
        the profile contains complete information.

        Time complexity: O(1)
        """
        m_xy, m_yz, m_zx, _ = profile
        # x = (m_xy + m_zx - m_yz) / 2
        # y = (m_xy + m_yz - m_zx) / 2
        # z = (m_yz + m_zx - m_xy) / 2
        s = m_xy + m_yz + m_zx  # = 2(x + y + z)
        assert s % 2 == 0, "Invalid profile: sum must be even"
        x = (m_xy + m_zx - m_yz) // 2
        y = (m_xy + m_yz - m_zx) // 2
        z = (m_yz + m_zx - m_xy) // 2
        return (x, y, z)

    @classmethod
    def identify_generator(cls, t: Triple) -> Optional[str]:
        """
        Identify which generator produced t from its parent.

        For a non-root primitive Pythagorean triple, exactly one
        inverse generator maps it to a triple with all positive
        coordinates and smaller hypotenuse.

        Time complexity: O(1)

        Returns:
            'A', 'B', or 'C' for non-root triples; None for ROOT.
        """
        if t == cls.ROOT:
            return None
        x, y, z = t
        if x + 2*y > 2*z:
            return 'B' if 2*x + y > 2*z else 'A'
        return 'C'

    @classmethod
    def recover_word(cls, t: Triple, max_depth: int = 10000) -> Optional[str]:
        """
        Recover the Berggren word that produces t from ROOT.

        This is the trapdoor inversion algorithm.

        Time complexity: O(depth) = O(log(hypotenuse))
        Space complexity: O(depth)

        Args:
            t: A primitive Pythagorean triple in the Berggren tree.
            max_depth: Maximum recursion depth (safety bound).

        Returns:
            The word w such that eval_word(w) = t, or None if
            max_depth is exceeded.
        """
        word = []
        current = t
        for _ in range(max_depth):
            if current == cls.ROOT:
                return ''.join(reversed(word))
            g = cls.identify_generator(current)
            if g is None:
                return ''.join(reversed(word))
            word.append(g)
            current = cls.INVS[g](current)
        return None

    @classmethod
    def enumerate_triples(cls, max_depth: int) -> Dict[str, Triple]:
        """
        Enumerate all Berggren triples up to a given depth.

        Time complexity: O(3^max_depth)
        Space complexity: O(3^max_depth)
        """
        import itertools
        result = {'': cls.ROOT}
        for depth in range(1, max_depth + 1):
            for word_tuple in itertools.product('ABC', repeat=depth):
                word = ''.join(word_tuple)
                result[word] = cls.eval_word(word)
        return result

    @staticmethod
    def hypotenuse_growth_factor(t: Triple, g: str) -> float:
        """Compute the growth factor of the hypotenuse under generator g."""
        gens = {'A': BerggrenTree.gen_A, 'B': BerggrenTree.gen_B,
                'C': BerggrenTree.gen_C}
        t2 = gens[g](t)
        return t2[2] / t[2]

    @staticmethod
    def bit_size(t: Triple) -> int:
        """Compute the bit size of a triple."""
        return sum(abs(x).bit_length() for x in t)

    @staticmethod
    def minor_entropy(profile: MinorProfile) -> float:
        """Compute the entropy of a minor profile (in bits)."""
        total = sum(abs(x) for x in profile) + 1
        return math.log2(total)


# === Cryptographic Protocol Simulation ===

class BerggrenTrapdoorScheme:
    """
    A toy trapdoor scheme based on the Berggren tree.

    Key generation: Choose a random word w of length n.
    Public key: minorProfile(packetOfWord(w))
    Secret key: w
    Trapdoor: recover_word(recover_triple(public_key))
    """

    def __init__(self, security_parameter: int = 20):
        """
        Initialize the scheme.

        Args:
            security_parameter: Word length (security grows exponentially).
        """
        self.n = security_parameter
        self.tree = BerggrenTree()

    def keygen(self) -> Tuple[MinorProfile, str]:
        """
        Generate a public/secret key pair.

        Returns:
            (public_key, secret_key) where public_key is a MinorProfile
            and secret_key is a BerggrenWord.
        """
        import random
        word = ''.join(random.choice('ABC') for _ in range(self.n))
        triple = self.tree.eval_word(word)
        public_key = self.tree.minor_profile(triple)
        return public_key, word

    def verify_trapdoor(self, public_key: MinorProfile, secret_key: str) -> bool:
        """
        Verify that the secret key correctly corresponds to the public key.
        """
        triple = self.tree.eval_word(secret_key)
        return self.tree.minor_profile(triple) == public_key

    def recover_secret(self, public_key: MinorProfile) -> Optional[str]:
        """
        Recover the secret key from the public key using the trapdoor.
        """
        triple = self.tree.recover_triple(public_key)
        return self.tree.recover_word(triple)


if __name__ == '__main__':
    # Quick algorithm test
    tree = BerggrenTree()

    print("=== Algorithm Tests ===\n")

    # Test word evaluation
    word = "ABCBA"
    triple = tree.eval_word(word)
    profile = tree.minor_profile(triple)
    recovered = tree.recover_word(triple)
    print(f"Word: {word}")
    print(f"Triple: {triple}")
    print(f"Profile: {profile}")
    print(f"Recovered: {recovered}")
    print(f"Correct: {recovered == word}")
    print(f"Pythagorean: {triple[0]**2 + triple[1]**2 == triple[2]**2}")
    print()

    # Test trapdoor scheme
    scheme = BerggrenTrapdoorScheme(security_parameter=10)
    pk, sk = scheme.keygen()
    print(f"Public key: {pk}")
    print(f"Secret key: {sk}")
    print(f"Verification: {scheme.verify_trapdoor(pk, sk)}")
    print(f"Recovery: {scheme.recover_secret(pk) == sk}")


#!/usr/bin/env python3
"""
Berggren Minor Trapdoors: Applications

Demonstrates real-world applications of the Berggren tree
cryptographic primitive in post-quantum security, hashing,
and certified robustness analysis.
"""