Formalize a complete, self-contained Lean 4 file proving a minimal but rigorous bridge from finite metric filtrations to a monotone edge-count profile, using only finite-set combinatorics and pseudometric structure.

Target theorem package:

Work with a type `α` carrying `[DecidableEq α] [PseudoMetricSpace α]` and a finite subset `X : Finset α`.

1. Define the Rips edge finset at scale `r : ℝ` as the finite collection of unordered pairs of distinct points of `X` whose distance is at most `r`. You may realize unordered pairs in whatever Lean-friendly way is easiest to prove with completely (for example, a finset of ordered pairs filtered by `x < y` if an order is available, or a quotient-free encoding such as pairs together with symmetry normalization). The implementation choice must support exact cardinality proofs without `sorry`.

2. Define `edgeCount X r : ℕ` as the cardinality of that edge finset.

3. Prove monotonicity in scale:
   `theorem edgeCount_mono {r s : ℝ} (hrs : r ≤ s) : edgeCount X r ≤ edgeCount X s`.
   The proof should be by explicit inclusion of the corresponding edge finsets and `Finset.card_mono` or an equivalent cardinality monotonicity lemma.

4. Prove the lower extremal statement in the precise hypothesis-driven form:
   `theorem edgeCount_eq_zero_of_forall_dist_gt
      (h : ∀ ⦃x⦄, x ∈ X → ∀ ⦃y⦄, y ∈ X → x ≠ y → r < dist x y) : edgeCount X r = 0`.
   This replaces the previous vague reference to “minimum nonzero distance” with a Lean-robust universal hypothesis.

5. Prove the upper extremal statement in the precise hypothesis-driven form:
   `theorem edgeCount_eq_choose_two_of_forall_dist_le
      (h : ∀ ⦃x⦄, x ∈ X → ∀ ⦃y⦄, y ∈ X → x ≠ y → dist x y ≤ r) : edgeCount X r = Nat.choose X.card 2`.
   If your edge representation is not literally unordered pairs, prove an equivalent cardinality formula that clearly specializes to `choose 2`.

6. Prove isometry invariance in a concrete finite-set form. A good target is:
   if `f : α → β` is distance-preserving and injective on `X`, then the edge counts of `X` and `X.image f` agree at every scale. If a bijection between finite subsets is easier, use that. The theorem statement should be explicit and fully proved.

7. Only after the above is complete, package the profile as a monotone map or monotone function `ℝ → ℕ` with a theorem recording monotonicity. Keep this lightweight; do not introduce a heavy “tropical valuation object” abstraction unless it is already available and immediately usable.

Requirements:
- No `sorry`, no truncated declarations, no placeholder theorem headers.
- Favor a representation of edges that makes proofs straightforward and checkable.
- Include short module-level documentation explaining the definitions and the four main theorems.
- If an existing catalog file already defines a suitable finite Rips graph object, reuse it only if it genuinely simplifies the proofs; otherwise stay self-contained.
- The final file should compile on its own and expose theorem names that clearly correspond to monotonicity, zero regime, saturated regime, and isometry invariance.

The key insight is that the bridge should be realized through a fully explicit finite combinatorial edge-count profile, not through ambitious abstractions whose proofs become opaque. Why now? The previous attempt already found the correct mathematical object, and the remaining obstacle is proof completeness; a smaller, hypothesis-driven formalization makes a complete verified result tractable immediately.