#!/usr/bin/env python3
"""
Algorithms for cardinal arithmetic and embedding feasibility.

Type-hinted implementations of the key algorithmic ideas from the
transfinite surface research.
"""

from enum import Enum
from dataclasses import dataclass
from typing import Optional


class CardinalForm(Enum):
    """Canonical forms for cardinal expressions."""
    FINITE = "finite"
    ALEPH = "aleph"      # ℵ_α for ordinal α
    POWER = "power"      # 2^κ for cardinal κ
    PRODUCT = "product"  # κ^λ


@dataclass
class Cardinal:
    """
    Symbolic representation of a cardinal number.
    
    Supports: finite values, aleph numbers, power expressions.
    """
    form: CardinalForm
    value: Optional[int] = None       # For FINITE
    index: Optional[int] = None       # For ALEPH: ℵ_index
    base: Optional['Cardinal'] = None # For POWER: 2^base
    
    def __repr__(self) -> str:
        if self.form == CardinalForm.FINITE:
            return str(self.value)
        elif self.form == CardinalForm.ALEPH:
            return f"ℵ_{self.index}"
        elif self.form == CardinalForm.POWER:
            return f"2^{self.base}"
        return "?"
    
    @staticmethod
    def finite(n: int) -> 'Cardinal':
        return Cardinal(CardinalForm.FINITE, value=n)
    
    @staticmethod
    def aleph(index: int) -> 'Cardinal':
        return Cardinal(CardinalForm.ALEPH, index=index)
    
    @staticmethod
    def power_of_two(base: 'Cardinal') -> 'Cardinal':
        return Cardinal(CardinalForm.POWER, base=base)
    
    @property
    def is_finite(self) -> bool:
        return self.form == CardinalForm.FINITE
    
    @property
    def is_countable(self) -> bool:
        return self.is_finite or (self.form == CardinalForm.ALEPH and self.index == 0)


def compare_cardinals_gch(a: Cardinal, b: Cardinal) -> str:
    """
    Compare two cardinals under the Generalized Continuum Hypothesis.
    
    Under GCH: 2^(ℵ_α) = ℵ_{α+1} for all ordinals α.
    
    Returns: '<', '=', '>', or '?' (unknown)
    """
    # Normalize under GCH
    a_norm = _normalize_gch(a)
    b_norm = _normalize_gch(b)
    
    if a_norm.form == CardinalForm.ALEPH and b_norm.form == CardinalForm.ALEPH:
        assert a_norm.index is not None and b_norm.index is not None
        if a_norm.index < b_norm.index:
            return '<'
        elif a_norm.index == b_norm.index:
            return '='
        else:
            return '>'
    
    if a_norm.is_finite and b_norm.is_finite:
        assert a_norm.value is not None and b_norm.value is not None
        if a_norm.value < b_norm.value:
            return '<'
        elif a_norm.value == b_norm.value:
            return '='
        else:
            return '>'
    
    if a_norm.is_finite and not b_norm.is_finite:
        return '<'
    if not a_norm.is_finite and b_norm.is_finite:
        return '>'
    
    return '?'


def _normalize_gch(c: Cardinal) -> Cardinal:
    """Normalize a cardinal expression under GCH."""
    if c.form == CardinalForm.POWER and c.base is not None:
        base_norm = _normalize_gch(c.base)
        if base_norm.form == CardinalForm.ALEPH and base_norm.index is not None:
            # 2^(ℵ_α) = ℵ_{α+1} under GCH
            return Cardinal.aleph(base_norm.index + 1)
        if base_norm.is_finite and base_norm.value is not None:
            return Cardinal.finite(2 ** base_norm.value)
    return c


def embedding_feasibility(
    source_dim: Cardinal, 
    target_dim: Cardinal,
    assume_ch: bool = True
) -> dict[str, object]:
    """
    Determine whether a set-theoretic injection from [0,1]^source_dim 
    to [0,1]^target_dim exists.
    
    Under CH (assume_ch=True):
    - |[0,1]^κ| = 2^κ for infinite κ (simplified under GCH)
    - Injection exists iff |source| ≤ |target|
    
    Returns dict with keys: 'feasible', 'reason', 'source_card', 'target_card'
    """
    if assume_ch:
        source_card = Cardinal.power_of_two(source_dim)
        target_card = Cardinal.power_of_two(target_dim)
        
        comparison = compare_cardinals_gch(source_card, target_card)
        
        if comparison == '>' :
            return {
                'feasible': False,
                'reason': f"|[0,1]^{source_dim}| = {source_card} > {target_card} = |[0,1]^{target_dim}|",
                'source_card': str(source_card),
                'target_card': str(target_card),
            }
        elif comparison in ('<', '='):
            return {
                'feasible': True,
                'reason': f"|[0,1]^{source_dim}| ≤ |[0,1]^{target_dim}|",
                'source_card': str(source_card),
                'target_card': str(target_card),
            }
        else:
            return {
                'feasible': None,
                'reason': "Cannot determine under current axioms",
                'source_card': str(source_card),
                'target_card': str(target_card),
            }
    
    return {
        'feasible': None,
        'reason': "Without CH, embedding feasibility may be independent of ZFC",
        'source_card': '?',
        'target_card': '?',
    }


def triangulation_bound(vertex_count: Cardinal) -> dict[str, object]:
    """
    Determine what spaces can be finitely triangulated with given vertex count.
    
    A triangulation with |V| vertices can cover at most |V| points (surjection bound).
    """
    if vertex_count.is_finite:
        return {
            'max_target_size': str(vertex_count),
            'can_cover_infinite': False,
            'can_cover_aleph1_surface': False,
            'reason': f"Surjection from {vertex_count} vertices covers ≤ {vertex_count} points"
        }
    elif vertex_count.form == CardinalForm.ALEPH:
        assert vertex_count.index is not None
        if vertex_count.index == 0:
            return {
                'max_target_size': 'ℵ₀',
                'can_cover_infinite': True,
                'can_cover_aleph1_surface': False,
                'reason': "ℵ₀ vertices cover ≤ ℵ₀ < 2^ℵ₁ points"
            }
        else:
            return {
                'max_target_size': f'ℵ_{vertex_count.index}',
                'can_cover_infinite': True,
                'can_cover_aleph1_surface': vertex_count.index >= 1,
                'reason': f"Need ≥ 2^ℵ₁ vertices; ℵ_{vertex_count.index} may suffice"
            }
    
    return {'max_target_size': '?', 'can_cover_infinite': None, 
            'can_cover_aleph1_surface': None, 'reason': 'Unknown'}


def cardinal_hierarchy_ch() -> list[tuple[str, str, str]]:
    """
    Return the cardinal hierarchy under CH as a list of (level, description, relation).
    """
    return [
        ("ℵ₀", "Countable: ℕ, ℤ, ℚ", ""),
        ("ℵ₁ = 𝔠", "Continuum: ℝ, ℝⁿ, [0,1]^ℕ", "< (strict)"),
        ("2^ℵ₁ = ℵ₂", "Second power: ≤ |[0,1]^ℵ₁|", "< (Cantor)"),
        ("2^ℵ₂ = ℵ₃", "Third power: ≤ |[0,1]^ℵ₂|", "< (Cantor)"),
    ]


# ── Demo ──

if __name__ == "__main__":
    print("=== Cardinal Comparison (GCH) ===")
    pairs = [
        (Cardinal.aleph(0), Cardinal.aleph(1)),
        (Cardinal.aleph(1), Cardinal.power_of_two(Cardinal.aleph(1))),
        (Cardinal.power_of_two(Cardinal.aleph(0)), Cardinal.aleph(1)),
    ]
    for a, b in pairs:
        result = compare_cardinals_gch(a, b)
        print(f"  {a} {result} {b}")
    
    print("\n=== Embedding Feasibility (CH) ===")
    tests = [
        (Cardinal.aleph(0), Cardinal.aleph(0)),
        (Cardinal.aleph(1), Cardinal.aleph(0)),
        (Cardinal.aleph(1), Cardinal.aleph(1)),
        (Cardinal.aleph(2), Cardinal.aleph(1)),
    ]
    for src, tgt in tests:
        result = embedding_feasibility(src, tgt)
        status = "✓" if result['feasible'] else "✗"
        print(f"  [0,1]^{src} → [0,1]^{tgt}: {status} ({result['reason']})")
    
    print("\n=== Triangulation Bounds ===")
    for v in [Cardinal.finite(10), Cardinal.aleph(0), Cardinal.aleph(1)]:
        result = triangulation_bound(v)
        print(f"  {v} vertices: max coverage = {result['max_target_size']}, "
              f"covers ℵ₁-surface: {result['can_cover_aleph1_surface']}")
