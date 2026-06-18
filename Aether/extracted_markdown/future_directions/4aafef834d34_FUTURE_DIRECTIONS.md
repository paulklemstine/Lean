# Future Directions: Berggren Spectral Hash Theory

## What Has Been Accomplished

We have formally verified in Lean 4 a complete chain of theorems establishing:

1. **Positivity preservation**: Berggren generators preserve positive Pythagorean triples
2. **Exponential growth**: Hypotenuse grows exponentially (bounded by 5·7^n) along any word path
3. **Freeness**: The positive Berggren semigroup is free on three generators — distinct words always produce distinct triples
4. **Collision separation**: Modular hashing is provably injective on bounded words when the modulus exceeds an explicit exponential threshold (10·7^L)
5. **Injectivity radius**: Quotient action graphs are tree-like up to logarithmic depth
6. **Walk support**: Distinct reachable states grow exponentially within the injectivity radius

These results constitute the first formally verified cryptographic hash construction based on Diophantine semigroup dynamics.

---

## Direction 1: Full Spectral Gap on Finite Quotients

**Goal**: Prove that the Cayley graph of the Berggren semigroup modulo a prime p has a uniform spectral gap.

**Approach**: The Berggren generators, when reduced modulo p, act on (ℤ/pℤ)³ restricted to the Pythagorean variety. The spectral gap measures how quickly random walks on this quotient graph mix. A uniform positive spectral gap (independent of p) would establish:

- Super-polynomial security amplification through random walks
- Expander graph properties usable for pseudorandom generation
- Connection to Selberg's eigenvalue conjecture via thin group theory

**Key challenge**: Linking the Berggren semigroup (a thin subgroup of O(2,1;ℤ)) to the representation-theoretic machinery used in Bourgain–Gamburd–Sarnak expansion theorems.

**Lean formalization target**:
```lean
theorem berggren_uniform_spectral_gap :
    ∃ ε : ℝ, 0 < ε ∧ ∀ p : ℕ, Nat.Prime p → 5 < p →
      ε ≤ spectralGap (berggrenQuotientGraph p)
```

---

## Direction 2: Strengthening the Growth Constant

**Goal**: Replace the crude bound 10·7^L with a tight constant.

**Current state**: Our proof uses the worst-case sup-norm bound: each generator multiplies the triple sup-norm by at most 7. This is tight for generator B (matrix !![1,2,2;2,1,2;2,2,3] has row sums up to 7), but the actual minimum growth of the hypotenuse is much better.

**Approach**: 
- Compute the spectral radius of each generator restricted to the positive cone
- Use the minimum singular value of the generators to get a sharper lower bound
- Prove that the minimum hypotenuse growth factor exceeds √2 per step

This would increase the provably collision-free depth from O(log N / log 7) to O(log N / log √2), roughly a 6× improvement in usable message length.

---

## Direction 3: Matrix-State Hashing

**Goal**: Extend the hash function from triple-based to matrix-based.

**Current state**: We hash the triple (a, b, c) = M·(3,4,5) mod N. But the full 3×3 matrix M = berggrenMatrixOfWord w carries more information.

**Benefits**:
- 9 output values instead of 3, giving larger hash output
- Matrix multiplication is algebraically richer, potentially harder to invert
- Matrix freeness (already proved) gives direct collision resistance

**Lean target**:
```lean
def matrixHash (N : ℕ) (w : List (Fin 3)) : Matrix (Fin 3) (Fin 3) (ZMod N) :=
  (berggrenMatrixOfWord w).map (fun x => (x : ZMod N))

theorem matrixHash_injective_bounded :
    ∃ C : ℕ, 1 < C ∧ ∀ N L, C ^ L < N →
      Set.InjOn (matrixHash N) {w | w.length ≤ L}
```

---

## Direction 4: Bad Moduli and Local Obstructions

**Goal**: Characterize which moduli N cause early collisions.

**Observations from computational experiments**:
- Primes p ≡ 1 (mod 4) seem to give the best injectivity radius
- Small primes (2, 3, 5) are "bad" because the Berggren generators have special structure mod these primes
- Composite moduli may have earlier collisions due to Chinese Remainder Theorem decomposition

**Approach**:
- Prove that for primes p > 5 with p ≡ 1 (mod 4), the injectivity radius is at least Ω(log p)
- Characterize the exact collision structure modulo 2, 3, and 5
- Study the action on the Pythagorean variety mod p and its connection to the Legendre symbol

---

## Direction 5: Generalization to Other Thin Semigroups

**Goal**: Build a general framework for semigroup-based hash functions.

**Candidate semigroups**:
1. **Apollonian packing semigroup**: Four generators acting on Descartes quadruples, with exponential curvature growth
2. **Markoff semigroup**: Three involutions generating all Markoff triples, with Vieta jumping giving growth control
3. **Hyperbolic matrix semigroups**: SL(2,ℤ) generators with spectral radius > 1
4. **Quaternionic semigroups**: Lipschitz or Hurwitz integers with norm growth

**Common framework requirements**:
- A free semigroup structure (or at least bounded-depth freeness)
- Exponential growth of a natural size function
- Effective residual finiteness (modular separation)
- Efficient evaluation (polynomial time in word length)

**Lean infrastructure**: Define a typeclass `HashableSemigroup` capturing the properties needed for collision resistance, then instantiate it for each example.

---

## Impact Assessment

These directions span from immediately achievable (Directions 2–4, requiring modest extensions of existing machinery) to deeply ambitious (Direction 1, requiring new spectral theory in Lean). Direction 5 has the highest potential impact: a verified library of algebraic hash functions would be a unique contribution to both cryptography and formal mathematics.

The key insight enabling all these directions is that **collision resistance from algebraic growth is fundamentally different from collision resistance from computational hardness**. The former gives unconditional guarantees within explicit parameter regimes, while the latter always requires unproven complexity assumptions. This distinction becomes especially important in the post-quantum setting, where the computational hardness landscape is rapidly shifting.
