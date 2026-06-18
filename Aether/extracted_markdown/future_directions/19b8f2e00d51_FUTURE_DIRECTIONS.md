# Future Directions — Spectral Graph Theory Meets Network Robustness

This cycle established, fully in Lean 4 (0 sorries), a faithful bridge between the
graph Laplacian and network robustness in
`Catalog/MachineLearning/SpectralRobustness/Core.lean`:

- `dirichletEnergy` = the Laplacian quadratic form `xᵀ L x`;
- `dirichletEnergy_mono` — adding edges only increases each signal's energy;
- `connected_iff_finrank_ker_eq_one` — Fiedler's criterion (connected ⇔ Laplacian
  nullity 1);
- `card_connectedComponent_antitone` / `finrank_ker_lapMatrix_antitone` — denser
  networks have no more components / no larger Laplacian nullity;
- `not_connected_iff_exists_nonconstant_zero_energy` — a spectral disconnection
  certificate.

Below are bold, testable conjectures to formalize in follow-up cycles. Each is
stated so that it can become a Lean theorem (or be refuted by a counterexample).

## C1. Algebraic connectivity as an ordered eigenvalue, and its monotonicity
Define `algConnectivity G : ℝ` as the second–smallest eigenvalue of `lapMatrix ℝ G`
(the Fiedler value), using a Courant–Fischer / min–max characterization over
signals orthogonal to the constants. **Conjecture:** `algConnectivity` is monotone
under edge addition, i.e. `H ≤ G → algConnectivity H ≤ algConnectivity G`, and
`algConnectivity G > 0 ↔ G.Connected`. This upgrades the pointwise
`dirichletEnergy_mono` and the nullity statement `connected_iff_finrank_ker_eq_one`
to the genuine eigenvalue level. Requires building min–max for `lapMatrix`, which
Mathlib currently lacks.

## C2. Fiedler's bound: algebraic connectivity ≤ vertex connectivity
**Conjecture:** for a graph that is not complete, `algConnectivity G ≤ κ(G)`, the
vertex connectivity (minimum number of vertices whose removal disconnects `G`).
This is the classical robustness inequality linking the spectral gap to the
combinatorial cut size. A formal first step is the edge version:
`algConnectivity G ≤ minEdgeCut G`.

## C3. Cheeger inequality for the normalized Laplacian
Define the conductance / isoperimetric number `h(G) = min_S |∂S| / min(vol S, vol Sᶜ)`
and the normalized Laplacian spectral gap `λ₂`. **Conjecture (Cheeger):**
`λ₂ / 2 ≤ h(G) ≤ sqrt(2 λ₂)`. The easy direction (`λ₂ / 2 ≤ h(G)`) is a realistic
formalization target using the Dirichlet-energy machinery already in this file:
plug the indicator-style test signals into `dirichletEnergy` and bound the
Rayleigh quotient.

## C4. Quantitative robustness: spectral lower bound on edges to disconnect
**Conjecture:** the minimum number of edges whose deletion disconnects a connected
graph on `n` vertices is at least `algConnectivity G` (and at least
`⌈ algConnectivity G ⌉`). Equivalently, a single edge deletion drops the algebraic
connectivity by at most a controlled amount: `algConnectivity G - algConnectivity (G \ e) ≤ 1`.
This is the eigenvalue-interlacing counterpart of `finrank_ker_lapMatrix_antitone`
and would give a verified "robustness margin" for ML network design.

## C5. Spectral robustness of graph products (scalability)
For the Cartesian product `G □ H`, the Laplacian spectrum is the sumset of the two
spectra. **Conjecture:** `algConnectivity (G □ H) = min (algConnectivity G) (algConnectivity H)`,
and consequently `dirichletEnergy_(G □ H)` decomposes additively over the factors.
This predicts how to build large robust networks (e.g. expander products) from
small robust ones, and pairs with the existing catalog work on expander walks.
