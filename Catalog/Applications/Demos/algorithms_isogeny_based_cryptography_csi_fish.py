#!/usr/bin/env python3
"""
Algorithms for CSIDH/CSI-FiSh Isogeny-Based Cryptography

Type-hinted implementations of the core cryptographic algorithms.
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional, Callable
import hashlib
import random


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class GroupAction:
    """A finite group acting on a finite set."""
    group_order: int
    set_size: int
    act: Callable[[int, int], int]

    def __post_init__(self) -> None:
        assert self.group_order == self.set_size, \
            "Free transitive action requires |G| = |X|"


@dataclass
class CSIDHParams:
    """CSIDH system parameters."""
    prime: int  # The prime p
    num_primes: int  # Number of small primes l_1, ..., l_n
    small_primes: List[int]  # The small primes
    bound: int  # Exponent bound B
    base_curve: int  # Base curve identifier


@dataclass
class CSIDHKeypair:
    """A CSIDH key pair."""
    secret_key: List[int]  # Exponent vector (e_1, ..., e_n) with |e_i| <= B
    public_key: int  # Public curve


@dataclass
class CSIFiShSignature:
    """A CSI-FiSh signature."""
    commitments: List[int]  # Commitment curves R_1, ..., R_t
    responses: List[int]  # Response elements z_1, ..., z_t
    challenges: List[bool]  # Challenge bits c_1, ..., c_t


# ============================================================
# CSIDH Key Exchange
# ============================================================

def csidh_keygen(action: GroupAction) -> CSIDHKeypair:
    """Generate a CSIDH key pair.

    Args:
        action: The group action (class group on curves)

    Returns:
        A key pair (secret, public)
    """
    secret = random.randint(0, action.group_order - 1)
    public = action.act(secret, 0)  # 0 = base curve
    return CSIDHKeypair(secret_key=[secret], public_key=public)


def csidh_shared_secret(action: GroupAction,
                         my_secret: int,
                         their_public: int) -> int:
    """Compute the CSIDH shared secret.

    Args:
        action: The group action
        my_secret: My secret key
        their_public: Their public key

    Returns:
        The shared secret curve
    """
    return action.act(my_secret, their_public)


def csidh_key_exchange(action: GroupAction) -> Tuple[int, int, bool]:
    """Full CSIDH key exchange protocol.

    Returns:
        (alice_shared, bob_shared, agreement)
    """
    alice = csidh_keygen(action)
    bob = csidh_keygen(action)

    alice_shared = csidh_shared_secret(action, alice.secret_key[0], bob.public_key)
    bob_shared = csidh_shared_secret(action, bob.secret_key[0], alice.public_key)

    return alice_shared, bob_shared, alice_shared == bob_shared


# ============================================================
# CSI-FiSh Identification Scheme
# ============================================================

def csifish_commit(action: GroupAction, base: int) -> Tuple[int, int]:
    """Prover's commitment phase.

    Returns:
        (commitment_curve, randomness)
    """
    r = random.randint(0, action.group_order - 1)
    commitment = action.act(r, base)
    return commitment, r


def csifish_respond(action: GroupAction,
                     secret: int,
                     randomness: int,
                     challenge: bool) -> int:
    """Prover's response to a challenge.

    Args:
        secret: The secret key s
        randomness: The commitment randomness r
        challenge: The verifier's challenge bit

    Returns:
        The response z
    """
    if challenge:
        # z = r * s^{-1} (in additive notation: z = r - s)
        return (randomness - secret) % action.group_order
    else:
        return randomness


def csifish_verify(action: GroupAction,
                    base: int,
                    public_key: int,
                    commitment: int,
                    challenge: bool,
                    response: int) -> bool:
    """Verify a CSI-FiSh identification transcript.

    Returns:
        True if the transcript is valid
    """
    if challenge:
        check = action.act(response, public_key)
    else:
        check = action.act(response, base)
    return check == commitment


# ============================================================
# CSI-FiSh Signature Scheme (via Fiat-Shamir)
# ============================================================

def fiat_shamir_hash(message: bytes,
                      commitments: List[int],
                      num_bits: int) -> List[bool]:
    """Hash message and commitments to challenge bits."""
    data = message + b"|" + b"|".join(str(c).encode() for c in commitments)
    h = hashlib.sha256(data).digest()
    bits = []
    for i in range(num_bits):
        byte_idx = i // 8
        bit_idx = i % 8
        if byte_idx < len(h):
            bits.append(bool((h[byte_idx] >> bit_idx) & 1))
        else:
            bits.append(False)
    return bits


def csifish_sign(action: GroupAction,
                  base: int,
                  secret: int,
                  message: bytes,
                  num_rounds: int) -> CSIFiShSignature:
    """Sign a message using CSI-FiSh.

    Args:
        action: The group action
        base: The base curve
        secret: The secret key
        message: The message to sign
        num_rounds: Number of parallel repetitions (security parameter)

    Returns:
        A CSI-FiSh signature
    """
    # Commit phase
    commitments = []
    randomnesses = []
    for _ in range(num_rounds):
        c, r = csifish_commit(action, base)
        commitments.append(c)
        randomnesses.append(r)

    # Challenge (Fiat-Shamir)
    challenges = fiat_shamir_hash(message, commitments, num_rounds)

    # Response phase
    responses = []
    for i in range(num_rounds):
        z = csifish_respond(action, secret, randomnesses[i], challenges[i])
        responses.append(z)

    return CSIFiShSignature(
        commitments=commitments,
        responses=responses,
        challenges=challenges,
    )


def csifish_verify_signature(action: GroupAction,
                              base: int,
                              public_key: int,
                              message: bytes,
                              signature: CSIFiShSignature) -> bool:
    """Verify a CSI-FiSh signature.

    Returns:
        True if the signature is valid
    """
    # Recompute challenges
    challenges = fiat_shamir_hash(
        message, signature.commitments, len(signature.challenges)
    )

    # Check challenges match
    if challenges != signature.challenges:
        return False

    # Verify each round
    for i in range(len(signature.challenges)):
        if not csifish_verify(
            action, base, public_key,
            signature.commitments[i],
            signature.challenges[i],
            signature.responses[i]
        ):
            return False

    return True


# ============================================================
# Special Soundness Extraction
# ============================================================

def extract_secret(action: GroupAction,
                    z0: int, z1: int) -> int:
    """Extract secret from two transcripts with different challenges.

    Given:
    - z0: response to challenge 0 (z0 * base = R)
    - z1: response to challenge 1 (z1 * pk = R)

    Returns:
        The extracted secret s = z0 * z1^{-1}
    """
    return (z0 - z1) % action.group_order


# ============================================================
# Random Self-Reducibility
# ============================================================

def rerandomize_gaip(action: GroupAction,
                      base: int,
                      target: int,
                      randomizer: int) -> Tuple[int, int]:
    """Rerandomize a GAIP instance.

    Given (base, target) where target = s * base,
    returns (r * base, r * target) which has the same solution s.

    Args:
        action: The group action
        base: The base point
        target: The target point
        randomizer: Random group element r

    Returns:
        (new_base, new_target) with same connector
    """
    new_base = action.act(randomizer, base)
    new_target = action.act(randomizer, target)
    return new_base, new_target


def worst_case_to_average_case(
    action: GroupAction,
    oracle: Callable[[int, int], int],
    base: int,
    target: int
) -> int:
    """Reduce worst-case GAIP to average-case using random self-reducibility.

    Args:
        action: The group action
        oracle: An oracle that solves GAIP on random instances
        base: The base point
        target: The target point

    Returns:
        The connector (secret) s such that target = s * base
    """
    r = random.randint(0, action.group_order - 1)
    new_base, new_target = rerandomize_gaip(action, base, target, r)
    # Oracle solves the rerandomized instance
    s = oracle(new_base, new_target)
    # By rerandomization lemma, s is also the solution to original instance
    return s


# ============================================================
# Key Space Analysis
# ============================================================

def csidh_key_space_size(num_primes: int, bounds: List[int]) -> int:
    """Compute the CSIDH key space size.

    Each exponent e_i ranges over [-B_i, B_i], giving 2*B_i + 1 choices.

    Args:
        num_primes: Number of small primes
        bounds: Exponent bounds [B_1, ..., B_n]

    Returns:
        The key space size
    """
    assert len(bounds) == num_primes
    result = 1
    for b in bounds:
        result *= (2 * b + 1)
    return result


def security_bits(key_space: int) -> int:
    """Compute security level in bits."""
    return key_space.bit_length() - 1


if __name__ == "__main__":
    # Example: Z/101Z with addition
    action = GroupAction(
        group_order=101,
        set_size=101,
        act=lambda g, x: (x + g) % 101,
    )

    # Key exchange
    a_shared, b_shared, ok = csidh_key_exchange(action)
    print(f"Key exchange: agreement={ok}")

    # Signing
    secret = 42
    pk = action.act(secret, 0)
    sig = csifish_sign(action, 0, secret, b"Hello world", 128)
    valid = csifish_verify_signature(action, 0, pk, b"Hello world", sig)
    print(f"Signature: valid={valid}")

    # Key space
    ks = csidh_key_space_size(74, [5] * 74)
    print(f"Key space (n=74, B=5): 2^{security_bits(ks)} bits")
