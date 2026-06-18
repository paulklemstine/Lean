# Appendix B: Selected Proofs

This appendix collects formal Lean 4 proofs of key results discussed in the book. The
complete source code is in the companion `.lean` files.

## B.1 Cantor's Diagonal Argument

The combinatorial core of the halting problem proof:

```lean
theorem cantor_diagonal {α : Type} :
    ¬ ∃ f : α → (α → Bool), Function.Surjective f := by
  intro ⟨f, hf⟩
  have g : α → Bool := fun a => !(f a a)
  obtain ⟨a, ha⟩ := hf g
  have : g a = f a a := congr_fun ha a
  simp [g] at this
```

## B.2 DFA Closure Under Complement

```lean
def DFA.complement (M : DFA Q Σ) (h : DecidablePred M.accept) : DFA Q Σ where
  start := M.start
  transition := M.transition
  accept := fun q => ¬ M.accept q
```

## B.3 Regular Languages Are Closed Under Intersection

Via the product construction:

```lean
def DFA.product (M₁ : DFA Q₁ Σ) (M₂ : DFA Q₂ Σ) : DFA (Q₁ × Q₂) Σ where
  start := (M₁.start, M₂.start)
  transition := fun (q₁, q₂) a => (M₁.transition q₁ a, M₂.transition q₂ a)
  accept := fun (q₁, q₂) => M₁.accept q₁ ∧ M₂.accept q₂
```

## B.4 The Pumping Lemma (Statement)

```lean
theorem pumping_lemma (M : DFA Q Σ) [Fintype Q] (w : List Σ) (hw : M.accepts w)
    (hlen : w.length ≥ Fintype.card Q) :
    ∃ x y z : List Σ,
      w = x ++ y ++ z ∧
      y.length ≥ 1 ∧
      (x ++ y).length ≤ Fintype.card Q ∧
      ∀ i : ℕ, M.accepts (x ++ List.join (List.replicate i y) ++ z) := by
  sorry -- Full proof requires pigeonhole on states
```

## B.5 Unsolvability of the Halting Problem (Informal → Formal Bridge)

The formal proof proceeds in several layers:

1. **Encoding**: Define an encoding of TMs as natural numbers (`⟨M⟩ : ℕ`).
2. **Universal machine**: Define a partial function `U : ℕ → ℕ → Option ℕ` that simulates
   encoded TMs.
3. **Diagonal construction**: Define `D(n) = if U(n, n) halts then loop else halt`.
4. **Contradiction**: Show `D` cannot have an encoding.

The formal details require a careful development of partial computable functions, which we
provide in the companion Lean files.

## B.6 Key Proof Techniques Used

| Technique                | Where Used                              |
|--------------------------|----------------------------------------|
| Diagonalization          | Halting problem, hierarchy theorems     |
| Pigeonhole principle     | Pumping lemma, NL = co-NL              |
| Simulation               | NFA→DFA, multi-tape→single-tape        |
| Reduction                | All undecidability results              |
| Padding argument         | Hierarchy theorems                     |
| Arithmetization          | IP = PSPACE                            |
| Probabilistic argument   | BPP, interactive proofs                |
