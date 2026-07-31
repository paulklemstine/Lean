# Thermodynamic Upper Bounds for Zero-Point-Energy Harvesting

**Aristotle**  
**July 31, 2026**

## Abstract

Quantum vacuum fluctuations motivate proposals for extracting useful energy from systems nominally prepared in a ground state. This paper gives a model-independent thermodynamic analysis of such proposals in discrete time. A harvesting process is represented by nonnegative sequences of stored usable energy, externally injected energy, and useful harvested output, linked by an exact per-cycle balance equation. Summing this equation yields a finite-horizon conservation identity. From it follow an absolute extraction bound, a net-export bound, exact input-output equality for cyclic devices, zero output for an unpowered device with no initial reserve, and decay of average net output below every positive target rate on sufficiently long horizons. The argument neither assigns an energy density to the vacuum nor denies quantum fluctuations; it isolates the consequence of treating those fluctuations as no unaccounted source in a globally conservative energy ledger. An auditing algorithm and numerical examples show how the bounds can be applied to proposed protocols.

## 1. Introduction

The ground state of a quantum field is not classically featureless. Field observables may have nonzero variance, ground-state correlations influence matter, and boundary conditions can alter measurable forces and spectra. These facts are sometimes interpreted as suggesting an accessible reservoir of “zero-point energy.” The thermodynamic question, however, is not whether vacuum fluctuations exist. It is whether a complete device can repeatedly convert them into useful work without consuming an initially prepared resource or receiving compensating energy from outside.

That distinction requires a system-wide account. A detector may become excited while a switching mechanism loses energy. A changing boundary may generate field quanta while the actuator does work. A feedback protocol may produce an apparent gain while its measurement, memory, and reset costs are excluded. A prepared nonclassical state may release energy, but its preparation is then a resource. Local or temporary output is therefore insufficient to establish net extraction.

We formulate a deliberately minimal model. Time is divided into cycles. Before each cycle, an apparatus and its designated local environment possess some nonnegative amount of usable stored energy. During the cycle, energy may be injected externally and useful energy may be exported. The sole dynamical assumption is an exact balance between these quantities. No microscopic Hamiltonian, field geometry, or measurement model is required.

The resulting bounds are universal within this accounting framework. Over any finite horizon, harvested output cannot exceed external input plus the initial reserve. After input is subtracted, net export cannot exceed that reserve. If the apparatus returns to its initial stored-energy condition, output equals input. If both initial reserve and external input vanish, every cycle has zero output. Finally, a finite reserve cannot support a persistent positive average net rate: its contribution is diluted as the number of cycles increases.

These statements are upper bounds, not claims about the detailed availability of any particular resource. They identify a necessary condition for a successful vacuum-powered engine: it would have to violate the assumed global balance or reveal that some item classified as “vacuum” was in fact a consumable nonequilibrium resource. The framework thus functions as both a theorem and an audit protocol.

## 2. Discrete thermodynamic model

### 2.1 Processes and accounting boundary

Fix cycles indexed by nonnegative integers $t=0,1,2,\ldots$. The accounting boundary must include the working device and every local component whose state is necessary to run or reset the protocol. Three real-valued sequences describe the process:

- $S_t$ is usable energy stored inside the accounting boundary immediately before cycle $t$;
- $I_t$ is energy injected from outside during cycle $t$;
- $H_t$ is useful harvested energy exported during cycle $t$.

The word “usable” is operational. It refers to energy that can contribute to subsequent output under the allowed protocol. It may include mechanical, electrical, chemical, thermal, detector, controller, or prepared-field resources. The model assumes

$$
S_t\ge 0,\qquad I_t\ge 0,\qquad H_t\ge 0
$$

for every $t$. The zero of stored energy is therefore chosen as the state with no remaining usable reserve, not necessarily as an absolute microscopic energy zero.

### Definition 1 (Conservative harvesting process)

A **conservative harvesting process** is a triple of nonnegative sequences $(S_t,I_t,H_t)$ satisfying the per-cycle energy balance

$$
S_{t+1}+H_t=S_t+I_t
\tag{1}
$$

for every nonnegative integer $t$.

Equation (1) states that energy available after a cycle, whether retained or exported, equals energy available before it plus external input. It excludes unaccounted sources and sinks. Losses may be included by enlarging the local environment so that dissipated energy remains in $S_t$, or may be represented explicitly as discussed in Section 8.

### Definition 2 (Finite-horizon totals)

For a horizon $N\ge 0$, define total injected and harvested energy by

$$
I^{(N)}=\sum_{t=0}^{N-1}I_t,
\qquad
H^{(N)}=\sum_{t=0}^{N-1}H_t.
\tag{2}
$$

Empty sums at $N=0$ are zero.

### Definition 3 (Net export)

The net useful energy exported through the first $N$ cycles is

$$
E_{\mathrm{net}}(N)
=
\sum_{t=0}^{N-1}(H_t-I_t)
=
H^{(N)}-I^{(N)}.
\tag{3}
$$

This quantity removes energy merely passed through from an external supply. Positive net export can occur over a finite interval if the initial reserve is depleted.

### Definition 4 (Cyclic horizon)

A horizon $N$ is **cyclic in stored usable energy** if

$$
S_N=S_0.
\tag{4}
$$

This condition is intentionally operational: the device has recovered the same amount of usable reserve. A more detailed physical model may require equality of the complete thermodynamic state, which is stronger and therefore still implies the energy condition relevant here.

## 3. Finite-horizon conservation

### Theorem 1 (Finite-Horizon Conservation Theorem)

For every conservative harvesting process and every integer $N\ge 0$,

$$
S_N+H^{(N)}=S_0+I^{(N)}.
\tag{5}
$$

#### Proof sketch

Sum equation (1) from $t=0$ through $t=N-1$:

$$
\sum_{t=0}^{N-1}S_{t+1}
+
\sum_{t=0}^{N-1}H_t
=
\sum_{t=0}^{N-1}S_t
+
\sum_{t=0}^{N-1}I_t.
$$

The stored-energy sums contain the same intermediate terms $S_1,\ldots,S_{N-1}$ on opposite sides. Canceling them leaves $S_N$ on the left and $S_0$ on the right, which gives (5). Equivalently, an induction on $N$ appends the balance equation for the final cycle to the identity at horizon $N$.

The theorem is an exact identity, not an asymptotic approximation. Every later result is a consequence of this telescoping account plus nonnegativity.

### Corollary 1 (Reserve-depletion identity)

For every horizon $N$,

$$
E_{\mathrm{net}}(N)=S_0-S_N.
\tag{6}
$$

#### Proof sketch

Rearrange (5) to obtain $H^{(N)}-I^{(N)}=S_0-S_N$, and use Definition 3.

Equation (6) identifies the source of every finite net surplus. If output exceeds input, stored usable energy has decreased by exactly the excess. Conversely, an increase in stored energy corresponds to negative net export.

## 4. Extraction and cyclicity bounds

### Theorem 2 (Absolute Extraction Bound)

For every conservative harvesting process and every horizon $N$,

$$
H^{(N)}\le S_0+I^{(N)}.
\tag{7}
$$

#### Proof sketch

Equation (5) gives $H^{(N)}=S_0+I^{(N)}-S_N$. Since $S_N\ge 0$, deleting the nonpositive term $-S_N$ yields (7).

This bound is tight. If a process ends with $S_N=0$, then every unit of initial reserve and injected energy has either been exported or, under this idealized lossless account, no longer remains stored; equality holds.

### Theorem 3 (Net-Export Bound)

For every conservative harvesting process and every horizon $N$,

$$
E_{\mathrm{net}}(N)\le S_0.
\tag{8}
$$

#### Proof sketch

By (6), $E_{\mathrm{net}}(N)=S_0-S_N$. Nonnegativity of $S_N$ gives the result.

The bound separates conversion from creation. Arbitrarily large gross output is possible if arbitrarily large input is supplied, but the output remaining after input is subtracted can never exceed the initial usable reserve.

### Theorem 4 (Cyclic Input-Output Equality)

If horizon $N$ is cyclic in stored usable energy, then

$$
H^{(N)}=I^{(N)}.
\tag{9}
$$

Equivalently, $E_{\mathrm{net}}(N)=0$.

#### Proof sketch

Insert $S_N=S_0$ into (5) and cancel the equal storage terms. Alternatively, use (6) directly.

The equality describes an ideal conservative cycle. With explicit nonnegative dissipation, output would be no greater than input. Importantly, a partial protocol that extracts energy but leaves the apparatus depleted is not a thermodynamic cycle. Restoring the apparatus must be included before the cyclic claim can be assessed.

## 5. Ground-state impossibility results

Within this accounting model, “ground state” means that the chosen boundary initially contains no usable reserve: $S_0=0$. This does not assert that all field observables vanish or that the microscopic ground-state energy is numerically zero. It specifies the operational resource relevant to extraction.

### Theorem 5 (Ground-State No-Harvesting Theorem)

Suppose $S_0=0$ and $I_t=0$ for every cycle $t$. Then, for every finite horizon $N$,

$$
H^{(N)}=0.
\tag{10}
$$

#### Proof sketch

Under the assumptions, equation (5) becomes

$$
S_N+H^{(N)}=0.
$$

Both $S_N$ and $H^{(N)}$ are nonnegative. A sum of two nonnegative real numbers is zero only when both terms are zero, so $H^{(N)}=0$.

### Theorem 6 (Pointwise Ground-State No-Harvesting Theorem)

Under the assumptions of Theorem 5, every cycle has zero harvested output:

$$
H_t=0
\tag{11}
$$

for all $t\ge 0$.

#### Proof sketch

Apply Theorem 5 at horizon $t+1$. The sum $H_0+\cdots+H_t$ is zero, and every summand is nonnegative. Therefore each summand, in particular $H_t$, is zero.

The pointwise statement rules out a proposed escape in which positive and negative harvested outputs cancel, because harvested output was defined to be nonnegative. If an experimental signal can take either sign, it must first be converted into an appropriate energy account; raw fluctuations are not themselves $H_t$.

## 6. Bounds on average net output

### Definition 5 (Average net output per cycle)

For $N>0$, define

$$
\overline P_N=\frac{E_{\mathrm{net}}(N)}{N}.
\tag{12}
$$

This has units of energy per cycle. If every cycle has duration $\Delta t>0$, physical average power is

$$
\overline{\mathcal P}_N
=
\frac{E_{\mathrm{net}}(N)}{N\Delta t}.
\tag{13}
$$

### Theorem 7 (Finite-Horizon Average Net-Power Bound)

For every $N>0$,

$$
\overline P_N\le \frac{S_0}{N}.
\tag{14}
$$

#### Proof sketch

Divide the Net-Export Bound (8) by the positive number $N$, preserving the inequality.

### Theorem 8 (Long-Horizon Vanishing-Rate Theorem)

For every target rate $\varepsilon>0$, there exists an integer $N_0\ge 0$ such that, for every $N\ge N_0$,

$$
\frac{E_{\mathrm{net}}(N)}{N}<\varepsilon,
\tag{15}
$$

with the convention that the ratio at $N=0$ is treated separately as zero. For positive horizons, one may choose any positive integer $N_0$ satisfying

$$
N_0>\frac{S_0}{\varepsilon}.
\tag{16}
$$

#### Proof sketch

By Theorem 7, $E_{\mathrm{net}}(N)/N\le S_0/N$. If $N>S_0/\varepsilon$, then multiplication by the positive quantities $N$ and $\varepsilon$ gives $S_0/N<\varepsilon$. Combining the inequalities proves (15).

This is an upper-bound statement, not necessarily convergence of $\overline P_N$ to zero from both sides. The average net output could be negative. What is excluded is a persistent positive lower bound on net output generated from a finite initial reserve.

### Corollary 2 (No sustained positive net power)

No conservative harvesting process with finite $S_0$ can satisfy $E_{\mathrm{net}}(N)/N\ge p$ for all sufficiently large $N$ for any fixed $p>0$.

#### Proof sketch

Apply Theorem 8 with $\varepsilon=p$. Eventually the average is strictly below $p$, contradicting the proposed sustained lower bound.

## 7. Auditing algorithm and numerical examples

The theory suggests a direct algorithm for evaluating a finite trajectory.

### Algorithm 1 (Conservation-ledger audit)

Given arrays $(S_0,\ldots,S_N)$, $(I_0,\ldots,I_{N-1})$, and $(H_0,\ldots,H_{N-1})$:

1. Check that all entries are nonnegative.
2. For every $t<N$, compute the residual
   $$
   r_t=S_{t+1}+H_t-S_t-I_t.
   $$
3. Reject the trajectory as outside the conservative model if any residual is nonzero beyond numerical tolerance.
4. Compute $I^{(N)}$, $H^{(N)}$, and $E_{\mathrm{net}}(N)=H^{(N)}-I^{(N)}$.
5. Confirm the global residual
   $$
   R=S_N+H^{(N)}-S_0-I^{(N)}
   $$
   is zero within tolerance.
6. Report the extraction margin $S_0+I^{(N)}-H^{(N)}=S_N$ and net-export margin $S_0-E_{\mathrm{net}}(N)=S_N$.
7. If $S_N=S_0$, report the cyclic equality $H^{(N)}=I^{(N)}$.

The algorithm uses $O(N)$ time and $O(1)$ additional memory when totals are accumulated in a single pass. It does not infer whether the chosen accounting boundary is physically complete; that remains the principal modeling responsibility.

### Example 1: depletion-supported surplus

Let

$$
S_0=10,
\qquad
(I_0,I_1,I_2,I_3)=(2,1,0,3),
$$

and

$$
(H_0,H_1,H_2,H_3)=(4,3,2,1).
$$

Using $S_{t+1}=S_t+I_t-H_t$ gives

$$
(S_0,S_1,S_2,S_3,S_4)=(10,8,6,4,6).
$$

The totals are $I^{(4)}=6$ and $H^{(4)}=10$, so $E_{\mathrm{net}}(4)=4$. This does not violate the bound: the reserve fell by exactly $4$, and (6) reads $4=10-6$.

### Example 2: an ideal cyclic converter

Let $S_0=5$, inputs $(2,0,1)$, and outputs $(1,1,1)$. The recurrence gives stored energies $(5,6,5,5)$. Since $S_3=S_0$, the process is cyclic. Both total input and total output equal $3$, as required by Theorem 4.

### Example 3: zero reserve and zero input

Set $S_0=0$ and $I_t=0$ for every $t$. The recurrence is $S_{t+1}=S_t-H_t$. If $H_t>0$ at any cycle, then with no earlier output the stored energy would become negative immediately or would require an earlier positive reserve, contradicting the assumptions. Theorems 5 and 6 express this globally and pointwise: all $H_t$ vanish.

### Example 4: amortization of a finite reserve

Suppose $S_0=12$ joules. Regardless of protocol details,

$$
\overline P_N\le \frac{12}{N}
$$

joules per cycle. Thus the upper bounds at $N=10$, $100$, and $1000$ are respectively $1.2$, $0.12$, and $0.012$ joules per cycle. To guarantee an upper bound below $0.01$ joules per cycle, it suffices to take $N>1200$.

## 8. Interpretation, scope, and extensions

### 8.1 What is established

The conclusions are conditional on a transparent physical premise: equation (1) is a complete energy balance. Under that premise, vacuum fluctuations cannot function as an unaccounted thermodynamic source. The argument is independent of the magnitude of fluctuation variances and does not require assigning a finite total energy to the vacuum.

The results distinguish four phenomena often conflated in discussions of extraction:

1. **Fluctuation:** a random or quantum observable has nonzero variance.
2. **Energy transfer:** one subsystem gains energy while another loses it.
3. **Resource consumption:** a prepared state or stored reserve is depleted.
4. **Net cyclic work:** useful output remains after all inputs and restoration costs are counted.

Only the fourth would constitute sustained harvesting by a cyclic engine, and Theorem 4 fixes its ideal net value at zero in the present model.

### 8.2 Accounting-boundary sensitivity

A conservation theorem cannot repair an incomplete ledger. If an actuator, clock, controller, measurement apparatus, reservoir, or state-preparation system lies outside the boundary, its contribution appears as unexplained output unless included in $I_t$. The model therefore supplies a falsifiable audit question: can every observed output be reconciled with changes in stored resources and measured inputs?

The stored quantity must also be chosen consistently. A system can have substantial microscopic energy while possessing no extractable work under allowed operations. Conversely, a squeezed field, excited detector, thermal gradient, or charged capacitor carries usable free energy even if described informally as part of the experimental “vacuum setup.” The theorem applies after these resources are classified in $S_t$ or $I_t$.

### 8.3 Dissipation

For a lossy process, introduce nonnegative dissipated energy $D_t$ and write

$$
S_{t+1}+H_t+D_t=S_t+I_t.
\tag{17}
$$

Summation yields

$$
S_N+H^{(N)}+D^{(N)}=S_0+I^{(N)}.
$$

Consequently,

$$
H^{(N)}\le S_0+I^{(N)}-D^{(N)},
$$

so dissipation strengthens the output bound. For a cyclic device,

$$
H^{(N)}=I^{(N)}-D^{(N)}\le I^{(N)}.
$$

### 8.4 Variable cycle durations

If cycle $t$ lasts $\Delta t_t>0$, total elapsed time is

$$
T_N=\sum_{t=0}^{N-1}\Delta t_t.
$$

The net-power bound becomes

$$
\frac{E_{\mathrm{net}}(N)}{T_N}\le \frac{S_0}{T_N}.
$$

Whenever $T_N\to\infty$, the upper bound tends to zero. This formulation separates physical power from energy per cycle.

### 8.5 Stochastic outputs

If $S_t$, $I_t$, and $H_t$ are random variables and the balance holds almost surely, then the finite-horizon identity holds almost surely by pathwise summation. Assuming integrability, taking expectations gives

$$
\mathbb E[S_N]+\sum_{t=0}^{N-1}\mathbb E[H_t]
=
\mathbb E[S_0]+\sum_{t=0}^{N-1}\mathbb E[I_t].
$$

Expected-output bounds follow from nonnegativity. Stronger tail and almost-sure asymptotic claims require additional probabilistic assumptions, but randomness alone does not evade pathwise conservation.

### 8.6 Continuous time

A continuous analogue would use an absolutely continuous stored-energy trajectory $S(t)$, injected and harvested power rates $i(t)$ and $h(t)$, and the almost-everywhere differential law

$$
S'(t)+h(t)=i(t).
$$

Integration over $[0,T]$ gives

$$
S(T)+\int_0^T h(t)\,dt
=
S(0)+\int_0^T i(t)\,dt,
$$

from which the same extraction, cyclicity, and average-power bounds follow. Establishing the appropriate balance from a specific open quantum dynamics is a substantive next step rather than an automatic consequence of the discrete model.

## 9. Applications

The framework can be applied to any proposal involving switching, measurement, boundary motion, or feedback:

- **Dynamical boundaries:** energy carried by generated excitations must be compared with actuator work and changes in boundary apparatus energy.
- **Detectors:** detector excitation must be balanced against switching work, motion, field-state changes, and the energy required to reset the detector.
- **Measurement and feedback:** controller batteries, memory erasure, and preparation costs belong in the input or storage accounts.
- **Prepared quantum states:** energy extracted from squeezed, coherent, thermal, or otherwise nonequilibrium states is consumption of a resource, not extraction from an unpowered ground state.
- **Casimir-type devices:** mechanical work during one stroke must be assessed together with the work needed to restore geometry and material configuration.

In each case, the theorem does not replace microscopic calculation. Rather, it constrains what any correct microscopic calculation may imply for a complete cycle.

## 10. Future work

Several extensions would make the framework more closely match physical implementations. A continuous-time treatment should derive integrated bounds from differential energy inequalities. Open-system models could identify injected work, heat, and harvested work within completely positive dynamics and connect the bounds to passivity and complete passivity. Stochastic formulations could provide expectation, tail-probability, and almost-sure long-time bounds. Multiple reservoirs would allow separate accounts for heat currents, measurement costs, feedback, and entropy production.

Further work should also characterize equality. The finite-horizon bound is attained when final usable storage vanishes and no omitted loss is present. For cyclic devices, equality of output and input represents ideal reversibility at the level of this coarse account. Relativistic localization raises a different question: local energy densities can display subtle behavior, including negative values relative to reference states, while global conservation remains intact. A regional bookkeeping framework could clarify how such observations coexist with global extraction bounds.

## 11. Conclusion

A minimal conservation ledger is sufficient to establish strong restrictions on zero-point-energy harvesting. For nonnegative stored, injected, and harvested energies satisfying $S_{t+1}+H_t=S_t+I_t$, summation gives exact finite-horizon conservation. Total output is no greater than initial reserve plus input; net export is no greater than the initial reserve; a cyclic device has output exactly equal to input; and an unpowered device with no initial reserve has zero output in total and in every individual cycle. The average net output from any finite reserve eventually falls below every positive target rate.

These results do not deny the physical effects of quantum vacuum fluctuations. They show why fluctuation, energy transfer, and sustainable work extraction must not be identified with one another. Any claimed engine must account for preparation, control, switching, restoration, and depletion. Once those entries are included, the vacuum cannot serve as an unrecorded thermodynamic fuel source without abandoning the global balance on which the analysis rests.