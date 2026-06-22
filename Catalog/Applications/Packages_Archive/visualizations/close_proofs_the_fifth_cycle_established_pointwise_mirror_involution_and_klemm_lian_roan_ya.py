from __future__ import annotations
from typing import Tuple


def mirror_swap(h11: int, h21: int, h31: int, h22: int) -> Tuple[int, int, int, int]:
    """Fourfold mirror map on free Hodge data: swap h11 <-> h31, fix h21,h22.
    This is an involution (applying twice is the identity)."""
    return (h31, h21, h11, h22)


def euler_char_klry(h11: int, h21: int, h31: int) -> Tuple[int, int]:
    """Apply the Klemm-Lian-Roan-Yau Chern-class relation to fix the central
    Hodge number h22, then return (h22, chi) where chi collapses to the
    F-theory formula 6*(8 + h11 + h31 - h21)."""
    h22 = 2 * (22 + 2 * h11 + 2 * h31 - h21)
    chi = 6 * (8 + h11 + h31 - h21)
    return h22, chi
