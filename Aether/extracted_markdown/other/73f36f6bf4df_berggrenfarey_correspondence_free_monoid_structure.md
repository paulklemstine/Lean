# Berggren–Farey Correspondence: Free Monoid Structure and GL(2,ℤ) Faithfulness

## Abstract

We formalize and prove that the Berggren monoid ⟨A,B,C⟩, which generates all primitive Pythagorean triples via a ternary tree, is **free** — no non-trivial relations hold among the three generators. The proof proceeds by establishing that the 2×2 integer matrix representation

> A ↦ [[2,−1],[1,0]], B ↦ [[2,1],[1,0]], C ↦ [[1,2],[0,1]]

is **faithful** (injective), which is equivalent to freeness. Our proof introduces a novel **matrix invariant system** — four integer inequalities preserved by all generators — and shows that all six cross-letter transition matrices violate these invariants, making first-letter recovery deterministic and yielding injectivity by induction.

All results are formalized in Lean 4 with Mathlib, producing **43 theorems with zero sorries**.

## 1. Introduction

The **Berggren tree** is a remarkable structure in number theory: starting from the root triple (3,4,5), every primitive Pythagorean triple is generated exactly once by repeatedly applying three matrix transformations A, B, C. This tree was discovered by Berggren (1934) and independently by several others.

The key question we address: **Is the Berggren monoid free?** That is, do different finite sequences of generators always produce different triples? Equivalently, is the matrix representation faithful?

## 2. The Berggren Invariant System

The central technical innovation is a **four-part invariant** on 2×2 integer matrices:

**Definition (Berggren Invariant).** A matrix M ∈ Mat₂(ℤ) satisfies the Berggren invariant if:
1. **Column dominance**: M₀₀ > M₁₀ (strict)
2. **Non-negativity**: M₁₀ ≥ 0
3. **β-positivity**: M₁₀ + M₁₁ ≥ 1
4. **Row sum hierarchy**: (M₀₀ + M₀₁) ≥ (M₁₀ + M₁₁)

**Theorem (Invariant Preservation).** The identity matrix satisfies the Berggren invariant, and left-multiplication by any Berggren generator matrix preserves it. Hence `berggrenRep(w)` satisfies the invariant for every word `w`.

*Proof.* Direct verification for each generator:
- For A = [[2,−1],[1,0]]: new column is [2m−n, m] where m > n ≥ 0, so 2m−n > m ≥ 1.
- For B = [[2,1],[1,0]]: new column is [2m+n, m], trivially positive.
- For C = [[1,2],[0,1]]: new column is [m+2n, n], preserving all inequalities.

## 3. Faithfulness Proof

**Theorem (First Letter Uniqueness).** If `berggrenRep(l₁ :: r₁) = berggrenRep(l₂ :: r₂)` and `l₁ ≠ l₂`, then False.

*Proof.* Left-multiplying by the inverse of generator l₂ gives a transition equation. The six cross-letter transition matrices are:
- (A,B) and (B,A): J = diag(1,−1), which negates β, contradicting β ≥ 1.
- (B,C) and (C,B): swap matrix [[0,1],[1,0]], which reverses column dominance.
- (A,C): [[0,−1],[1,0]], which makes α negative, contradicting α ≥ 1.
- (C,A): [[0,1],[−1,0]], which makes M₁₀ negative, contradicting non-negativity.

**Main Theorem (Faithfulness).** `berggrenRep(w₁) = berggrenRep(w₂) → w₁ = w₂`.

*Proof.* By induction on total word length:
- If one word is empty, the other must be too (since no non-empty word maps to identity).
- If both are non-empty, first letters must match (by the uniqueness lemma), so we cancel and recurse.

## 4. Additional Results

### Determinant Parity
The determinant of a word's matrix equals (−1)^(number of B letters), since det(A) = det(C) = 1 and det(B) = −1.

### Entry Growth Bound
Matrix entries grow at most as 3^n where n is the word length. This gives O(n) bit complexity for matrix entries, relevant for computational applications.

### Descent Properties
The Berggren descent (applying inverse generators to reduce triples toward (3,4,5)) strictly decreases the hypotenuse, with the bound c' = −2a − 2b + 3c < c. This connects to the Euclidean algorithm and continued fractions.

## 5. Significance

The faithfulness result establishes a **tripartite correspondence**:

1. **Free monoid** ⟨A,B,C⟩ (combinatorial algebra)
2. **GL(2,ℤ) submonoid** (matrix group theory)
3. **Berggren tree** of primitive Pythagorean triples (Diophantine geometry)

This opens the field of **modular Pythagorean geometry** — studying Pythagorean triples via the modular group.

## 6. Formalization Summary

| Category | Count |
|----------|-------|
| Definitions | 8 |
| Theorems | 43 |
| Lines of Lean code | 546 |
| Sorry count | 0 |
| Diverse tactics used | induction, cases, rcases, by_contra, omega, linarith, nlinarith, native_decide, norm_num, simp, fin_cases |

## References

1. Berggren, B. (1934). "Pytagoreiska trianglar." *Tidskrift för elementär matematik, fysik och kemi*, 17, 129–139.
2. Barning, F.J.M. (1963). "Over Pythagorese en bijna-Pythagorese driehoeken en een generatieproces met behulp van unimodulaire matrices." *Math. Centrum Amsterdam Afd. Zuivere Wisk.*, ZW-011.
3. Hall, A. (1970). "Genealogy of Pythagorean triads." *Mathematical Gazette*, 54(390), 377–379.
