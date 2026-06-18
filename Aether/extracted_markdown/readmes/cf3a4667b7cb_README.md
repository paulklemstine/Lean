# Python Demos: Eigenvalue Repulsion Visualizations

Run each script from the project root:
```bash
python "Random Matrix/demos/demo1_eigenvalue_repulsion.py"
```

## Scripts and Generated Figures

| Script | Figures | Description |
|--------|---------|-------------|
| `demo1_eigenvalue_repulsion.py` | `eigenvalue_repulsion.png` | Spacing distributions for GOE/GUE vs. Poisson — shows P(s) ~ s^β repulsion |
| `demo2_coulomb_gas.py` | `coulomb_gas_simulation.png` | Eigenvalues as charged particles at β = 1, 2, 4 with semicircle comparison |
| `demo3_vandermonde_landscape.py` | `vandermonde_landscape.png`, `vandermonde_3d_surface.png`, `coulomb_energy_landscape.png` | 2D/3D landscapes of the Vandermonde factor and Coulomb energy |
| `demo4_semicircle_law.py` | `semicircle_law.png` | Convergence to the Wigner semicircle as N → ∞ |
| `demo5_eigenvalue_dynamics.py` | `dyson_brownian_motion.png`, `level_repulsion_trajectories.png` | Dyson Brownian motion: eigenvalue trajectories with avoided crossings |
| `demo6_vandermonde_identity.py` | `fundamental_identity_verification.png`, `two_point_repulsion.png` | Numerical verification of the Vandermonde-Coulomb identity |

## Requirements
```
numpy, matplotlib, scipy
```
