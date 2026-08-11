# Computational Evidence

Small-case data gathered before formalisation. All numbers below were recomputed and the
structural claims they support are now *proved* in the Lean files
`Catalog/Novelty/MultiwaySortingRadix.lean`, `Catalog/Novelty/SortingDirectSum.lean`,
`Catalog/Novelty/SortingFluctuationPenalty.lean` and
`Catalog/Novelty/PriorSensitiveSorting.lean`.  Only the table in §1 is additionally
machine-checked inside Lean (`MultiwaySorting.optimal_depth_table_five`, by `decide`); the
remaining tables are numerical exploration, not verification.

## 1. Multiway radix: depth versus work ledger (`n = 5`, `n! = 120`)

`d(q) = ⌈log_q 120⌉`, work ledger `d·log q` in nats, baseline `log 120 = 4.7875`.

| q  | d(q) | d·log q | log(n!) | log(n!) + log q |
|----|------|---------|---------|-----------------|
| 2  | 7    | 4.8520  | 4.7875  | 5.4806          |
| 3  | 5    | 5.4931  | 4.7875  | 5.8861          |
| 4  | 4    | 5.5452  | 4.7875  | 6.1738          |
| 5  | 3    | 4.8283  | 4.7875  | 6.3969          |
| 10 | 3    | 6.9078  | 4.7875  | 7.0901          |

Every row satisfies `log(n!) ≤ d·log q < log(n!) + log q`: depth falls with the radix while
the ideal information balance is unchanged.  This is the content of
`MultiwaySorting.radix_independent_work_lower_bound` and
`MultiwaySorting.optimal_radix_work_sandwich`.  The depth column is verified in Lean
(`optimal_depth_table_five`).

No new integer sequence arises here: the row `d(2)` over `n = 1,2,3,…` is
`0, 1, 3, 5, 7, 10, 13, 16, 19, 22` = `⌈log₂ n!⌉` (`Nat.clog 2 (n!)`), the classical
information-theoretic sorting bound.  No OEIS lookup was performed.

## 2. Direct sum: entropy adds, history states multiply

| (m, n) | log₂ m! + log₂ n! | log₂(m!·n!) | minimal history states |
|--------|-------------------|-------------|------------------------|
| (3, 3) | 2.5850 + 2.5850   | 5.1699      | 36                     |
| (4, 2) | 4.5850 + 1.0000   | 5.5850      | 48                     |
| (5, 3) | 6.9069 + 2.5850   | 9.4919      | 720                    |

Additivity of the left column against multiplicativity of the right column is exactly
`SortingDirectSum.sorting_direct_sum_synthesis`.  A protocol with 49 history states on the
`(4,2)` system necessarily has a non-surjective history map
(`SortingDirectSum.block_history_strict_of_garbage`).

## 3. Fluctuation penalty: counterexample hunt for the strict inequality

Setting `kT = 1`, `n = 3`, baseline `F = log 6 = 1.79176`, two trajectories with
`p = (1/2, 1/2)` and Jarzynski constraint `½e^{-W₁} + ½e^{-W₂} = 1/6`:

| W₁      | W₂      | ⟨W⟩     | ⟨W⟩ − F | p^R = (q₁, q₂)   | D(p‖p^R) |
|---------|---------|---------|---------|------------------|----------|
| 1.29176 | 2.83793 | 2.06485 | 0.27309 | (0.82436, 0.17564)| 0.27309 |
| 1.79176 | 1.79176 | 1.79176 | 0.00000 | (0.5, 0.5)       | 0.00000  |

The excess matches the relative entropy to all printed digits, and vanishes exactly in the
constant-work row.  No counterexample to strictness was found; the search is now moot since
`SortingFluctuation.sorting_fluctuation_penalty` proves it, and
`dissipated_work_eq_relEntropy` proves the identity exactly (not approximately).

## 4. Nonuniform priors (`n = 3`, six orderings)

Dyadic prior `p = (1/2, 1/4, 1/8, 1/16, 1/32, 1/32)`:

* `H(p) = 0.5 + 0.5 + 0.375 + 0.25 + 0.15625 + 0.15625 = 1.9375` bits;
* uniform value `log₂ 6 = 2.58496` bits;
* Shannon–Fano lengths `(1,2,3,4,5,5)` give expected length `1.9375` — zero overshoot,
  since all probabilities are dyadic.

So the biased prior is `0.647` bits cheaper than the uniform baseline, illustrating
`PriorSensitiveSorting.entropy_lt_logb_card_of_nonuniform` and
`PriorSensitiveSorting.prior_sensitive_synthesis`.  The observed slack of the achievable
sorter over `H(p)` never exceeded one bit in any tested prior, which is what the proved
bound asserts.
