from dataclasses import dataclass
from typing import List, Sequence, Tuple


@dataclass(frozen=True)
class Bar:
    """A persistence bar: a birth time and a death time."""
    birth: float
    death: float


def persistence(b: Bar) -> float:
    """Lifetime of a bar: death - birth."""
    return b.death - b.birth


def betti_count(tau: float, barcode: Sequence[Bar]) -> int:
    """Number of bars whose persistence strictly exceeds tau.  O(n) time."""
    return sum(1 for b in barcode if tau < persistence(b))


def certify_recovery(true_bars: Sequence[Bar],
                     noisy_bars: Sequence[Bar],
                     tau: float,
                     eps: float) -> Tuple[bool, float]:
    """Certify the hypotheses of the Betti-recovery theorem.

    Returns (certified, R) where R = m_obs / (2*eps) is the margin-to-noise
    ratio.  If certified is True, the noisy Betti count provably equals the
    true Betti count.  O(n) time.
    """
    eps_obs = max(abs(persistence(n) - persistence(t))
                  for n, t in zip(noisy_bars, true_bars))
    m_obs = min(abs(persistence(t) - tau) for t in true_bars)
    R = m_obs / (2.0 * eps)
    certified = (eps_obs <= eps) and (2.0 * eps < m_obs)
    return certified, R
