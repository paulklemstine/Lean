

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "3f92e6d5",
    "description": "Building on cycle 51575ef7 (Q=0.794), which proved 68 theorems in Bridges. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting. Original direction: The key insight is that the catalog already contains two independently developed notions of behavioral indistinguishability \u2014 coalgebraic neural behavior in `Bridges/CoalgebraicNeuralMyhillNerode.lean` and algebraic congruence classes in `Algebra/ProofSpectra/Core.lean` \u2014 and these should be linked ",
    "domains": [
      "Bridges"
    ],
    "id": "push_51575ef7_4ab3c654",
    "priority_score": 0.894,
    "research_mode": "team",
    "source_exp_id": "51575ef7",
    "status": "in_progress",
    "timestamp": "2026-06-15T06:29:51.421066+00:00",
    "title": "Deepening: Functorial comparison between neural observation pseudometrics and proof-spectru"
  },
  {
    "consumed_by_exp_id": "afe8c8b6",
    "description": "Cycle 51575ef7 (Q=0.794) proved 68 theorems in Bridges but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: The key insight is that the catalog already contains two independently developed notions of behavioral indistinguishability \u2014 coalgebraic neural behavior in `Bridges/CoalgebraicNeuralMyhillNerode.lean",
    "domains": [
      "Bridges"
    ],
    "id": "sorry_fill_51575ef7_28c2f32a",
    "priority_score": 0.8440000000000001,
    "research_mode": "team",
    "source_exp_id": "51575ef7",
    "status": "in_progress",
    "timestamp": "2026-06-15T06:29:52.059077+00:00",
    "title": "Close Proofs: Functorial comparison between neural observation pseudometrics and pro"
  },
  {
    "consumed_by_exp_id": "",
    "description": "Cycle a64f762c (Q=0.705) proved 6 theorems in Bridges but left 3 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Salvage the original bridge by shrinking it to a single arithmetic theorem package that is fully self-contained and only depends on elementary `Nat` lemmas plus the existing valuation-depth adapter. D",
    "domains": [
      "Bridges"
    ],
    "id": "sorry_fill_a64f762c_e509fc82",
    "priority_score": 0.7547200000000001,
    "research_mode": "team",
    "source_exp_id": "a64f762c",
    "status": "available",
    "timestamp": "2026-06-15T06:54:22.120757+00:00",
    "title": "Close Proofs: Functorial Lipschitz comparison between valuation depth and tropical v"
  },
  {
    "consumed_by_exp_id": "b9cc2fac",
    "description": "# Future Directions \u2014 Categorical Tropicalization of Rips Filtrations and Interleaving Stability\n\nThis cycle established (in `Catalog/Bridges/CategoricalTropicalRipsInterleaving.lean`,\n0 sorries, axioms `propext / Classical.choice / Quot.sound` only) the order-theoretic\ncore of persistence stability:\n\n- a Rips filtration `ripsOf` of an **arbitrary symmetric distance** `d : \u03b1 \u2192 \u03b1 \u2192 \u211d`\n  (generalizing the instance-bound `ripsGraph` of\n  `Applications/PoincareData/MetricFiltration.lean`, related by `ripsMetric_eq_ripsOf`);\n- the `\u03b4`-**interleaving** relation `Interleaved`, with `interleaved_refl`,\n  `interleaved_symm`, `interleaved_mono`, and the **tropical composition law**\n  `interleaved_comp` (shifts add: `\u03b4\u2081 \u2299 \u03b4\u2082 = \u03b4\u2081 + \u03b4\u2082`);\n- the **stability theorem** `rips_stability` (`|d \u2212 d'| \u2264 \u03b4 \u21d2 \u03b4`-interleaved) and its\n  metric form `rips_stability_dist`;\n- the **interleaving (pseudo)distance** `interleavingDist` satisfying the tropical\n  valuation / pseudometric axioms `interleavingDist_self`, `interleavingDist_comm`,\n  `interleavingDist_triangle`.\n\nThe conjectures below are concrete, falsifiable next steps. Each is phrased so that a\nfollow-up cycle can either produce a Lean theorem or a Lean counterexample.\n\n---\n\n## Conjecture 1 \u2014 Sharpness of stability (the converse Lipschitz bound)\n\n**Statement.** For finite `\u03b1` with two symmetric distances `d, d'`, the interleaving\ndistance of their Rips filtrations *equals* a tropical \"best matching\" of edge-birth\nscales:\n```\ninterleavingDist (ripsOf d) (ripsOf d') = sInf { \u03b4 \u2265 0 | \u2200 x y, |d x y \u2212 d' x y| \u2264 \u03b4 on the relevant edge set }.\n```\nIn particular stability is **tight**: there exist `d, d'` with\n`interleavingDist (ripsOf d) (ripsOf d') = \u2016d \u2212 d'\u2016_\u221e`. \n\n**Test.** Prove `interleavingDist (ripsOf d) (ripsOf d') \u2265 f(d,d')` for an explicit\nlower bound `f`, complementing the upper bound `rips_stability_dist`; or exhibit a\n3-point counterexample where the inequality is strict. *Falsifiable:* a single finite\nexample with strict gap refutes tightness.\n\n## Conjecture 2 \u2014 `interleavingDist` is a genuine extended pseudometric on filtrations\n\n**Statement.** Replacing `\u211d` by `\u211d\u22650\u221e` and dropping the nonemptiness hypotheses,\n`interleavingDistExt : (\u211d \u2192 SimpleGraph \u03b1) \u2192 (\u211d \u2192 SimpleGraph \u03b1) \u2192 \u211d\u22650\u221e` is a true\n`PseudoEMetricSpace` structure on the type of **monotone** filtrations, with\n`interleavingDistExt F G = 0 \u2194 F = G` on left-continuous filtrations.\n\n**Test.** Build the `\u211d\u22650\u221e`-valued version, prove `edist`-style triangle/symmetry\nunconditionally (the `sInf \u2205 = \u22a4` convention removes the `Nonempty` hypotheses that are\nload-bearing in the current `\u211d` version), and register a `PseudoEMetricSpace` instance.\n*Falsifiable:* exhibiting two distinct left-continuous monotone filtrations at distance\n`0` refutes the separation half.\n\n## Conjecture 3 \u2014 Functoriality: 1-Lipschitz maps contract interleaving distance\n\n**Statement.** A `1`-Lipschitz map `\u03c6 : (\u03b1, d) \u2192 (\u03b1', d')` (i.e. `d' (\u03c6x)(\u03c6y) \u2264 d x y`)\ninduces graph homomorphisms `ripsOf d \u03b5 \u2192 ripsOf d' \u03b5` for all `\u03b5`, and the induced map\non filtrations is **`1`-Lipschitz for `interleavingDist`**. Hence `interleavingDist`\nis a functor `(FiniteMetricSpaces, Lipschitz) \u2964 (Filtrations, interleaving)` landing in\nthe tropical-enriched category of \u00a72.\n\n**Test.** Define the induced filtration map, prove the homomorphism existence, and prove\nthe contraction `interleavingDist (push \u03c6 F) (push \u03c6 G) \u2264 interleavingDist F G`.\n*Falsifiable:* a Lipschitz map increasing some interleaving distance.\n\n## Conjecture 4 \u2014 Tropical idempotency: an ultrametric refinement via single-linkage\n\n**Statement.** The **`\u03c0\u2080`/connected-components** functor applied to `ripsOf d` recovers\nthe single-linkage (sub-)dendrogram, and the associated \"merge-scale\" distance\n`d_SL x y := inf { \u03b5 | x, y connected in ripsOf d \u03b5 }` is an **ultrametric**, with\n```\ninterleavingDist (ripsOf d) (ripsOf d') \u2264 \u2016d_SL \u2212 d'_SL\u2016_\u221e \u2264 \u2016d \u2212 d'\u2016_\u221e,\n```\nso single-linkage is a tropical-idempotent contraction of the metric. This directly\nlinks this bridge to `Bridges/CategoricalTropicalUltrametric.lean`: `d_SL` is the\nultrametric *reconstructed* from the tropical valuation data of the filtration.\n\n**Test.** Define `d_SL` via `SimpleGraph.Reachable` on `ripsOf d \u03b5`, prove the strong\ntriangle inequality `d_SL x z \u2264 max (d_SL x y) (d_SL y z)`, and prove the chained bound.\n*Falsifiable:* a 4-point example violating the ultrametric inequality for `d_SL`.\n\n## Conjecture 5 \u2014 Stability of the connectivity (Poincar\u00e9) threshold\n\n**Statement.** Define the connectivity threshold `\u03b8(d) := inf { \u03b5 | ripsOf d \u03b5 is\nconnected }` (the `MetricFiltration`-level \"Poincar\u00e9 threshold\" of the catalog). Then\n`\u03b8` is **`1`-Lipschitz** in the `sup`-distance:\n```\n|\u03b8(d) \u2212 \u03b8(d')| \u2264 \u2016d \u2212 d'\u2016_\u221e,\n```\nas a corollary of `rips_stability` plus monotone-connectivity transfer along\ninterleavings (`\u03b4`-interleaved filtrations have connectivity thresholds within `\u03b4`).\n\n**Test.** Prove \"connected at scale `\u03b5` \u21d2 connected at scale `\u03b5 + \u03b4` for a\n`\u03b4`-interleaved filtration\" (using `interleaved.fg` and `SimpleGraph.Connected.mono`),\nthen derive the Lipschitz bound on `\u03b8`. *Falsifiable:* a finite perturbation moving the\nconnectivity threshold by more than `\u2016d \u2212 d'\u2016_\u221e`.\n",
    "domains": [
      "Algebra",
      "Tropical"
    ],
    "id": "fd_1940",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "88475cc5",
    "status": "in_progress",
    "timestamp": "2026-06-15T06:30:12.551925+00:00",
    "title": "(in `Catalog/Bridges/CategoricalTropicalRipsInterleaving."
  }
];
