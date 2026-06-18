Formalize the 1-Lipschitz stability of the rank functor on persistence modules. This is a core result in topological data analysis / persistent homology theory.

## Context

In persistent homology, a persistence module over ℕ valued in Finset β is a monotone sequence of finite sets: `f : ℕ → Finset β` such that `f m ⊆ f n` whenever `m ≤ n`. Two such modules are ε-interleaved if each set in one is contained in the corresponding shifted set in the other. The rank functor sends such a module to the monotone sequence of cardinalities. The 1-Lipschitz property says the interleaving distance does not increase under the rank functor.

## Definitions to formalize

```lean
-- A persistence module over ℕ valued in Finset β
def IsPersMod {β : Type*} [Fintype β] (f : ℕ → Finset β) : Prop :=
  ∀ m n, m ≤ n → f m ⊆ f n

-- ε-interleaving of two persistence modules
def IsInterleaved {β : Type*} [Fintype β] (ε : ℕ) (f g : ℕ → Finset β) : Prop :=
  ∀ n, f n ⊆ g (n + ε) ∧ g n ⊆ f (n + ε)

-- Interleaving distance (as an ENat, ⊤ if no interleaving exists)
def interleavingDist {β : Type*} [Fintype β] (f g : ℕ → Finset β) : ℕ∞ :=
  ⨅ ε ∈ {ε | IsInterleaved ε f g}, (ε : ℕ∞)
```

## Theorems to prove

1. `rank_monotone`: If `IsPersMod f` then `∀ m n, m ≤ n → (f m).card ≤ (f n).card`.
   Proof: Direct from `Finset.card_le_card` and the monotonicity hypothesis.

2. `rank_preserves_interleaving`: If `IsInterleaved ε f g` then `∀ n, (f n).card ≤ (g (n + ε)).card ∧ (g n).card ≤ (f (n + ε)).card`.
   Proof: Apply `Finset.card_le_card` to each inclusion from `IsInterleaved`.

3. `rank_lipschitz`: `interleavingDist (fun n => (f n).card) (fun n => (g n).card) ≤ interleavingDist f g`.
   Proof: If `IsInterleaved ε f g` then by theorem 2, the rank modules are also ε-interleaved. So the set of valid ε for the rank modules contains the set of valid ε for the original modules, hence the infimum is no larger.

4. `rank_isPersMod`: If `IsPersMod f` then the rank module `fun n => (f n).card` satisfies the ℕ-valued monotonicity condition.

## CRITICAL INSTRUCTIONS
- ONLY formalize the persistence module / rank functor content described above.
- Do NOT include any content about Korselt's criterion, Carmichael numbers, number theory, graph theory, surreal numbers, oracle traces, or any unrelated topic.
- Every definition and theorem must be about persistence modules, interleaving, or the rank functor.
- All proofs must type-check without circular reasoning.
- Use `Finset.card_le_card` from Mathlib as the key lemma.
- Use `ENat` or `WithBot ℕ` for the interleaving distance to handle the case of no interleaving.