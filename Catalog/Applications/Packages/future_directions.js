

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "",
    "description": "# Future Directions \u2014 Consciousness as Integrated Information\n\nThis cycle established a fully verified core for Integrated Information Theory\n(IIT) in `Catalog/Novelty/IntegratedInformation.lean`:\n\n- `mutualInfo` of a joint `FinDist (\u03b1 \u00d7 \u03b2)` (KL to the product of marginals),\n  with `mutualInfo_nonneg` (Gibbs), `mutualInfo_eq_zero_iff` (vanishes iff\n  independent), and `mutualInfo_swap` (symmetry of a part vs. its complement).\n- The Minimum-Information-Partition value `Phi` over a nonempty family of cuts\n  `Finset (Finset \u03b9)`, with `Phi_nonneg` and `Phi_eq_zero_iff` (\u03a6 vanishes iff\n  some candidate cut decomposes the system into independent parts).\n- Witnesses: `mutualInfo_prod = 0` (product = unintegrated) and\n  `mutualInfo_correlatedBits_pos` (a maximally correlated pair of bits has \u03a6 > 0).\n\nThe following conjectures are precise, falsifiable, and ready to formalize.\n\n## C1 \u2014 Capacity upper bound on integration\nFor any `P : FinDist (\u03b1 \u00d7 \u03b2)`,\n`mutualInfo P \u2264 Real.log (Fintype.card \u03b1)` and symmetrically\n`mutualInfo P \u2264 Real.log (Fintype.card \u03b2)`; hence\n`mutualInfo P \u2264 Real.log (min (Fintype.card \u03b1) (Fintype.card \u03b2))`.\n*Test:* equality is approached by the correlated-bits family generalized to\n`n`-ary perfectly-correlated states, where `mutualInfo = Real.log n`.\n\n## C2 \u2014 Chain rule / superadditivity for a refined cut\nFor a tripartite `P : FinDist (\u03b1 \u00d7 (\u03b2 \u00d7 \u03b3))` with the induced bipartite views,\n`mutualInfo (X ; (Y,Z)) = mutualInfo (X ; Y) + condMutualInfo (X ; Z | Y)`,\nwhere the conditional term is `\u2265 0`. Consequently coarsening a cut (merging two\nsides) cannot decrease the cross-cut mutual information.\n*Test:* with all three parts independent both sides are `0`; with `Z = X` the\nconditional term carries the full `mutualInfo (X;X)`.\n\n## C3 \u2014 Data-processing monotonicity of \u03a6\nIf `K` is a stochastic channel applied independently within each side of a cut\n(a per-part `Markov` map), then `mutualInfo (pushforward K P) \u2264 mutualInfo P`,\nand therefore `Phi` cannot increase under intra-part processing. Formally: a\ncolumn-stochastic matrix acting on one factor is a contraction for `mutualInfo`.\n*Test:* the identity channel gives equality; a constant (information-erasing)\nchannel sends `mutualInfo` to `0`.\n\n## C4 \u2014 \u03a6 = 0 \u21d4 global Markov factorization\nFor the full MIP family `cuts = univ \\ {\u2205, univ}` over `\u03b9`,\n`Phi P cuts hne = 0` iff `P` factorizes as a product across *some* nontrivial\nbipartition of the elements `\u03b9`. Strengthen to: a system is \"minimally\nintegrated\" exactly when its dependency hypergraph is disconnected.\n*Test:* a product distribution over two element-blocks has `Phi = 0`; the\nall-bits-equal distribution over `n \u2265 2` elements has `Phi > 0` for every cut.\n\n## C5 \u2014 Continuity / stability of integration\n`mutualInfo` is uniformly continuous in `P` on the simplex away from the\nboundary, and globally bounded; quantitatively, for distributions within total\nvariation `\u03b4`, `|mutualInfo P \u2212 mutualInfo Q|` is controlled by a modulus\n`\u03c9(\u03b4)` independent of `P, Q` (a Csisz\u00e1r\u2013Kemperman\u2013Kullback-style bound).\n*Test:* perturbing the correlated-bits masses by `\u03b5` changes `mutualInfo`\ncontinuously, with no jump at independence.\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_0000",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "91104b94",
    "status": "available",
    "timestamp": "2026-06-24T10:35:57.730575+00:00",
    "title": "Fully verified core for Integrated Information Theory"
  }
];
