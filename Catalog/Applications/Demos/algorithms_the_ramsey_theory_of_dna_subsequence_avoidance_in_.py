"""
Algorithms for DNA k-mer Ramsey Theory
======================================

Type-hinted implementations of the core algorithms for computing
k-mer repeat thresholds, subword complexity, and composition bias effects.
"""

from typing import List, Dict, Tuple, Optional
from collections import Counter
import math


def kmer_at(seq: List[str], k: int, i: int) -> Tuple[str, ...]:
    """Extract the k-mer (contiguous substring of length k) starting at position i."""
    return tuple(seq[i:i + k])


def all_kmers(seq: List[str], k: int) -> List[Tuple[str, ...]]:
    """Extract all contiguous k-mers from a sequence."""
    if k <= 0 or len(seq) < k:
        return []
    return [kmer_at(seq, k, i) for i in range(len(seq) - k + 1)]


def is_repeat_free(seq: List[str], k: int) -> bool:
    """Check if a sequence is k-repeat-free (all k-mers are distinct)."""
    kmers = all_kmers(seq, k)
    return len(kmers) == len(set(kmers))


def subword_complexity(seq: List[str], k: int) -> int:
    """Compute the subword complexity C(k): number of distinct k-mers."""
    return len(set(all_kmers(seq, k)))


def ramsey_threshold(alpha: int, k: int) -> int:
    """Compute the Ramsey threshold: α^k + k.
    
    Any sequence of this length over alphabet of size α must contain
    a repeated k-mer (by the pigeonhole principle).
    """
    return alpha ** k + k


def max_repeat_free_length(alpha: int, k: int) -> int:
    """Maximum length of a k-repeat-free sequence over alphabet of size α.
    
    This equals α^k + k - 1, achieved by de Bruijn sequences.
    """
    return alpha ** k + k - 1


def composition_vector(seq: List[str]) -> Dict[str, int]:
    """Compute the composition vector (symbol frequency counts)."""
    return dict(Counter(seq))


def effective_alphabet_size(seq: List[str]) -> int:
    """Compute the effective alphabet size (number of distinct symbols used)."""
    return len(set(seq))


def compositional_entropy(seq: List[str]) -> float:
    """Compute the compositional (Shannon) entropy of a sequence.
    
    H = -Σ p_i log₂(p_i)
    
    Maximum entropy (uniform distribution) gives the largest effective
    alphabet and longest possible repeat-free sequences.
    """
    if not seq:
        return 0.0
    counts = Counter(seq)
    n = len(seq)
    entropy = 0.0
    for count in counts.values():
        if count > 0:
            p = count / n
            entropy -= p * math.log2(p)
    return entropy


def effective_threshold_from_bias(seq: List[str], k: int) -> int:
    """Estimate the effective repeat-free threshold based on composition bias.
    
    Uses the effective alphabet size to compute a tighter bound than
    the worst-case α^k + k - 1.
    """
    eff_alpha = effective_alphabet_size(seq)
    return eff_alpha ** k + k - 1


def find_first_repeat(seq: List[str], k: int) -> Optional[Tuple[int, int, Tuple[str, ...]]]:
    """Find the first repeated k-mer in a sequence.
    
    Returns (position1, position2, kmer) or None if no repeat exists.
    """
    seen: Dict[Tuple[str, ...], int] = {}
    for i in range(len(seq) - k + 1):
        kmer = kmer_at(seq, k, i)
        if kmer in seen:
            return (seen[kmer], i, kmer)
        seen[kmer] = i
    return None


def subword_complexity_profile(seq: List[str], max_k: Optional[int] = None) -> List[Tuple[int, int]]:
    """Compute the subword complexity profile C(k) for k = 1, 2, ..., max_k.
    
    Returns list of (k, C(k)) pairs. The profile characterizes sequence
    richness across all scales.
    """
    if max_k is None:
        max_k = min(len(seq), 20)
    profile = []
    for k in range(1, max_k + 1):
        if k > len(seq):
            break
        profile.append((k, subword_complexity(seq, k)))
    return profile


def generate_de_bruijn(alpha: int, k: int) -> List[int]:
    """Generate a de Bruijn sequence of order k over alphabet {0, 1, ..., α-1}.
    
    A de Bruijn sequence contains every possible k-mer exactly once,
    achieving the maximum repeat-free length of α^k + k - 1.
    
    Uses Martin's algorithm.
    """
    alphabet = list(range(alpha))
    sequence: List[int] = []
    
    a = [0] * (alpha * k)
    
    def db(t: int, p: int) -> None:
        if t > k:
            if k % p == 0:
                sequence.extend(a[1:p + 1])
        else:
            a[t] = a[t - p]
            db(t + 1, p)
            for j in range(a[t - p] + 1, alpha):
                a[t] = j
                db(t + 1, t)
    
    db(1, 1)
    # Extend to make it a proper repeat-free sequence
    sequence.extend(sequence[:k - 1])
    return sequence


def compute_repeat_distance(seq: List[str], k: int) -> List[int]:
    """Compute the distance between consecutive occurrences of each k-mer.
    
    Returns a list of distances. Shorter distances indicate more
    compressed/repetitive regions.
    """
    positions: Dict[Tuple[str, ...], List[int]] = {}
    for i in range(len(seq) - k + 1):
        kmer = kmer_at(seq, k, i)
        if kmer not in positions:
            positions[kmer] = []
        positions[kmer].append(i)
    
    distances = []
    for pos_list in positions.values():
        for j in range(1, len(pos_list)):
            distances.append(pos_list[j] - pos_list[j - 1])
    return sorted(distances)
