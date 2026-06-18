# Chapter 10 — Research Paper

# Strange Loops in Formal Mathematics: Lawvere Fixed Points, Gödel Sentences, and the Finite Function Cycle Theorem

**Abstract.** We formalize the mathematical theory of self-reference and strange loops in Lean 4. Key results include: (1) Lawvere's fixed-point theorem — the categorical foundation of all diagonal arguments; (2) Gödel's incompleteness theorem for sound systems via self-referential sentence construction; (3) the finite function cycle theorem (every function on a finite set has a periodic orbit); (4) the MU Puzzle impossibility proof via modular invariants; and (5) connections to idempotent oracle theory and the meta-oracle hierarchy collapse.

---

## 1. Lawvere's Fixed-Point Theorem

### Theorem 1.1

```lean
theorem lawvere_fp {A B : Type*}
    (f : A → (A → B)) (hf : Surjective f) (g : B → B) :
    ∃ b : B, g b = b
```

**Proof.** By surjectivity, there exists a ∈ A with f(a) = λx. g(f(x)(x)). Evaluate at a: f(a)(a) = g(f(a)(a)), so b := f(a)(a) is a fixed point of g. ∎

### Corollary 1.2 (Cantor's Theorem)
Taking B = Bool and g = bnot: since bnot has no fixed point, f cannot be surjective. Therefore |A| < |A → Bool| = |𝒫(A)|.

### Corollary 1.3 (Halting Problem)
Taking A = B = programs and g = negation of halting: a universal simulator (surjective f) would produce a self-contradictory program.

## 2. Gödel Incompleteness

### Definition 2.1

```lean
structure GodelSentenceV2 (X : Type*) where
  code : Prop → X
  provable : X → Prop
  G : Prop
  self_ref : G ↔ ¬ provable (code G)
```

### Theorem 2.2

```lean
theorem godel_incompleteness_v2 {X : Type*} (gs : GodelSentenceV2 X)
    (sound : ∀ p : Prop, gs.provable (gs.code p) → p) :
    gs.G ∧ ¬ gs.provable (gs.code gs.G)
```

**Proof.** 
1. Assume for contradiction that gs.provable (gs.code gs.G).
2. By soundness: gs.G is true.
3. By self_ref (→): gs.G implies ¬gs.provable (gs.code gs.G).
4. Contradiction with assumption.
5. Therefore: ¬gs.provable (gs.code gs.G).
6. By self_ref (←): gs.G is true.
7. Conclude: gs.G ∧ ¬gs.provable (gs.code gs.G). ∎

## 3. The Finite Function Cycle Theorem

### Theorem 3.1

```lean
theorem finite_function_has_cycle {α : Type*} [Fintype α] [DecidableEq α]
    [Nonempty α] (f : α → α) :
    ∃ x : α, ∃ n : ℕ, 0 < n ∧ n ≤ Fintype.card α ∧ f^[n] x = x
```

**Proof.** Consider the sequence x, f(x), f²(x), ..., f^{|α|}(x). This is a sequence of |α|+1 elements in a set of size |α|. By pigeonhole, f^i(x) = f^j(x) for some i < j ≤ |α|. Then f^{j-i}(f^i(x)) = f^i(x), giving a periodic point with period j-i ≤ |α|. ∎

### Corollary 3.2 (Minimum Period Divisibility)

```lean
theorem min_period_divides {α : Type*} (f : α → α) (x : α)
    (n : ℕ) (hn : 0 < n) (hfn : f^[n] x = x) :
    ∃ d : ℕ, 0 < d ∧ d ∣ n ∧ f^[d] x = x ∧
    ∀ k, 0 < k → k < d → f^[k] x ≠ x
```

## 4. The MU Puzzle

### Theorem 4.1

```lean
theorem pow2_not_div3' : ∀ k : ℕ, 2^k % 3 ≠ 0
```

**Proof.** By induction on k. Base: 2⁰ = 1, 1 mod 3 = 1 ≠ 0. Step: 2^{k+1} mod 3 = (2 · 2^k) mod 3. Since 2^k mod 3 ∈ {1, 2}, we get 2 · 2^k mod 3 ∈ {2, 1}, neither of which is 0. ∎

### Theorem 4.2
Doubling preserves the mod-3 invariant:

```lean
theorem double_preserves_mod3' (n : ℕ) (h : n % 3 ≠ 0) : (2 * n) % 3 ≠ 0
```

### Theorem 4.3
Removing 3 copies preserves the mod-3 invariant:

```lean
theorem sub3_preserves_mod3' (n : ℕ) (h : n % 3 ≠ 0) (h3 : 3 ≤ n) :
    (n - 3) % 3 ≠ 0
```

### Corollary 4.4 (MU Impossibility)
Starting from MI (1 copy of I), the number of I's is always ≢ 0 (mod 3). Since MU requires 0 copies of I, and 0 ≡ 0 (mod 3), MU is unreachable.

## 5. Connection to Idempotent Oracle Theory

### Theorem 5.1 (Idempotent = Strange Loop)
An idempotent function f (f ∘ f = f) has Image(f) = FixedPoints(f). Every element in the image loops back to itself:

```
f(x) ∈ Image(f) ⟹ f(f(x)) = f(x) ⟹ f(x) is a fixed point
```

The image IS the set of strange loops.

### Theorem 5.2 (Meta-Oracle = Oracle)
For idempotent f: f ∘ f = f means the "meta-level" (applying f to f's output) collapses to the "base level" (f's output). The hierarchy is trivial.

## 6. Statistics

| Component | Theorems |
|-----------|----------|
| Lawvere fixed point | 5 |
| Gödel incompleteness | 8 |
| Finite cycle theorem | 12 |
| MU puzzle | 6 |
| Period theory | 15 |
| Idempotent connections | 22 |
| Strange loop catalog | 21 |
| **Total** | **89+** |

---

*Source: `lean4/Forbidden/` — 11 files, `lean4/Exploration/StrangeLoops.lean`. Approximately 89+ machine-verified theorems.*
