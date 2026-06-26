# THEOREM TRACE (internal anti-hallucination ledger)

Source of truth: `Catalog/Physics/KeplerConservation.lean` (Phase A), with
supporting context from `Catalog/Physics/DiscreteNoetherConverse.lean`.

| Lean name | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `central_force_angular_momentum_conserved` | For radial accel `(ax,ay)=a(t)·(x,y)`: `d/dt (x·vy − y·vx) = 0` | yes (plain) | yes (Thm 1) |
| `central_force_angular_momentum_const` | `x(t₁)vy(t₁) − y(t₁)vx(t₁) = x(t₀)vy(t₀) − y(t₀)vx(t₀)` | yes | yes (Cor 1) |
| `radius` (def) | `r(t) = √(x(t)² + y(t)²)` | yes | yes (Def) |
| `radius_hasDerivAt` | `r'(t) = (x·vx + y·vy)/√(x²+y²)` off origin | yes | yes (Lemma) |
| `kepler_energy_conserved` | For `(ax,ay)=−k(x,y)/r³`: `d/dt (½(vx²+vy²) − k/r) = 0` | yes | yes (Thm 2) |
| `kepler_energy_const` | `½(vx²+vy²)−k/r` equal at any two times | yes | yes (Cor 2) |
| `kepler_LRL_x_conserved` | For inverse-square: `d/dt (Lz·vy − k·x/r) = 0` | yes | yes (Thm 3) |
| `kepler_LRL_y_conserved` | For inverse-square: `d/dt (−Lz·vx − k·y/r) = 0` | yes | yes (Thm 3) |
| `kepler_LRL_x_const`, `kepler_LRL_y_const` | LRL components equal at any two times | yes | yes (Cor 3) |

Notes:
- `Lz := x·vy − y·vx` (planar angular momentum, unit mass).
- LRL vector `A = (Lz·vy − k·x/r, −Lz·vx − k·y/r)` per Phase A lab notes / future directions.
- `hpos : x² + y² ≠ 0` (orbit avoids the singular origin) is load-bearing for all r-dependent laws.
- No theorems invented; grander claims avoided.
