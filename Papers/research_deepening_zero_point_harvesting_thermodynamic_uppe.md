# Information-Adjusted Energy Bounds for Finite-State Cyclic Harvesters

**Aristotle**  
**August 1, 2026**

## Abstract

We study a discrete-time energy-harvesting process whose controller performs finite computations. Each step divides available energy among terminal storage, useful exported energy, and the Landauer cost of distinctions erased by the controller. For a map from a nonempty finite input state space to an output state space, we define erased capacity as the base-two logarithm of the ratio between the number of inputs and the number of outputs actually reached. We prove that this quantity is nonnegative, vanishes exactly for injective maps, and is bounded below by the logarithmic cardinality gap between the input and ambient output spaces. Summing the one-step energy balance yields an exact finite-horizon conservation identity. It implies both an upper bound on useful output plus actual erasure cost and a coarser bound depending only on state-space cardinalities. Finally, we prove a rigidity theorem: at positive temperature, a closed process with no external input that returns to its initial stored energy can export no useful energy, and every computation in the cycle must be injective. Numerical algorithms illustrate the accounting and separate actual image-based loss from codomain-based lower bounds. The results provide a general obstruction to cyclic vacuum-energy extraction schemes that omit the physical cost of finite-state control.

## 1. Introduction

Proposals to extract useful energy from equilibrium fluctuations often focus on a microscopic source while idealizing the controller that observes, selects, and resets. Yet selection requires physical records. If two previously distinguishable records are merged into one, the controller has performed a logically irreversible operation. At positive temperature, erasing one bit carries the Landauer price $k_BT\ln 2$, where $k_B$ is Boltzmann's constant and $T$ is temperature.

This paper develops a finite-horizon model in which energetic and informational accounting are explicit parts of one balance law. The formulation is deliberately independent of a particular quantum-field mechanism. It applies to any discrete cyclic harvester with nonnegative stored, injected, and exported energies, finite controller state sets, and a Landauer debit for erased distinctions.

The central identity is obtained by telescoping local balances. If $S_t$ denotes stored energy, $I_t$ external input, $H_t$ useful output, and $L_t$ computational dissipation, then

$$
S_{t+1}+H_t+L_t=S_t+I_t
$$

implies

$$
S_N+\sum_{t=0}^{N-1}H_t+\sum_{t=0}^{N-1}L_t
=S_0+\sum_{t=0}^{N-1}I_t.
$$

The information-theoretic contribution is made concrete by finite cardinalities. A step $f_t:A_t\to B_t$ reaches an image $f_t(A_t)$. The erased capacity is

$$
e_t=\log_2|A_t|-\log_2|f_t(A_t)|.
$$

It is the logarithmic loss of distinguishable alternatives, not merely the difference between the sizes of two declared data types. Because $f_t(A_t)\subseteq B_t$, it also satisfies

$$
e_t\ge \log_2|A_t|-\log_2|B_t|.
$$

This gives an information-adjusted extraction inequality using only the cardinalities of the input and output spaces.

The final result is a rigidity statement rather than only a bound. If the process is unpowered, cyclic in stored energy, and at positive temperature, then the sum of nonnegative useful outputs and Landauer costs is zero. Hence every output and every erasure vanishes separately. Zero erasure is equivalent to injectivity of the finite computation, so all steps are logically reversible.

## 2. Finite computations and erased capacity

### 2.1 State maps and reached outputs

Let $A$ be a nonempty finite set of possible input records, let $B$ be a finite set of possible output records, and let

$$
f:A\to B
$$

be a deterministic computation. Define its reached output set by

$$
\operatorname{Im}(f)=\{f(a):a\in A\}.
$$

Write $M=|A|$, $R=|\operatorname{Im}(f)|$, and $Q=|B|$. Nonemptiness of $A$ gives $R\ge 1$, while elementary counting gives

$$
1\le R\le M,
\qquad
R\le Q.
$$

The distinction between $R$ and $Q$ matters. An output type may permit many nominal values even though a particular computation reaches only a few of them. Irreversibility depends on collisions in the actual map and therefore on $R$.

### 2.2 Erased capacity

**Definition 2.1 (Erased capacity).** The erased capacity of $f$, in bits, is

$$
e(f)=\log_2 M-\log_2 R
=\log_2\!\left(\frac{M}{R}\right).
$$

This definition measures the maximum finite-state information capacity lost when the $M$ alternatives are represented by only $R$ reached outputs. Since $R\le M$, one has $e(f)\ge 0$.

**Lemma 2.2 (Ambient cardinality lower bound).** For every map $f:A\to B$ with nonempty finite $A$ and finite $B$,

$$
\log_2|A|-\log_2|B|\le e(f).
$$

**Proof sketch.** The image is a subset of $B$, so $R\le Q$. The base-two logarithm is increasing on positive numbers, giving $\log_2R\le\log_2Q$. Subtracting these quantities from $\log_2M$ reverses their positions and proves the claim. $\square$

The bound can be strict. If $|A|=64$, $|B|=64$, but $f$ reaches only $8$ outputs, the ambient gap is $0$ whereas the actual erased capacity is $3$ bits. The ambient bound is useful when only type sizes are available, but image counting gives the exact finite-state quantity.

### 2.3 Logical reversibility

**Theorem 2.3 (Zero-erasure reversibility criterion).** Let $A$ be a nonempty finite set. For a map $f:A\to B$,

$$
e(f)=0
$$

if and only if $f$ is injective.

**Proof sketch.** The equality $e(f)=0$ is equivalent to $\log_2M=\log_2R$. Positivity and strict monotonicity of the logarithm imply $M=R$. A function on a finite domain has an image with the same cardinality as its domain exactly when no two domain elements collide, which is precisely injectivity. Conversely, if $f$ is injective, all $M$ input states have distinct outputs, so $R=M$ and $e(f)=0$. $\square$

Thus the finite map loses no capacity exactly when its input is recoverable from its output. Surjectivity onto the ambient codomain is irrelevant: an injective map into a larger space has zero erased capacity even if many codomain states are unused.

## 3. The information–energy process

Fix discrete times $t\in\mathbb{N}$. For each time, let $A_t$ be a nonempty finite input state set, let $B_t$ be a finite output state set, and let

$$
f_t:A_t\to B_t
$$

be the controller's computational step.

**Definition 3.1 (Information-accounted process).** An information-accounted energy process consists of:

1. stored energy $S_t\ge 0$ at each time $t$;
2. externally injected energy $I_t\ge 0$ at each step;
3. useful harvested energy $H_t\ge 0$ exported at each step;
4. finite computations $f_t:A_t\to B_t$;
5. constants $k_B\ge 0$ and $T\ge 0$;
6. the one-step balance law

$$
S_{t+1}+H_t+L_t=S_t+I_t,
$$

where the erased bits and Landauer cost are

$$
e_t=e(f_t)
=\log_2|A_t|-\log_2|f_t(A_t)|,
$$

and

$$
L_t=e_t k_BT\ln 2.
$$

We call

$$
p=k_BT\ln 2
$$

the bit price. Under the stated nonnegativity assumptions, $p\ge 0$, $e_t\ge 0$, and $L_t\ge 0$.

The equality in Definition 3.1 is an ideal accounting relation. It does not claim that every physical device attains the minimum Landauer dissipation. Additional friction, leakage, and control overhead can be included as extra nonnegative terms, which only strengthen the resulting upper bounds on useful output.

## 4. Finite-horizon conservation

**Theorem 4.1 (Finite-horizon information–energy conservation).** For every information-accounted process and every horizon $N\ge 0$,

$$
S_N+\sum_{t=0}^{N-1}H_t+\sum_{t=0}^{N-1}L_t
=S_0+\sum_{t=0}^{N-1}I_t.
$$

For $N=0$, both sums are empty and the identity reduces to $S_0=S_0$.

**Proof sketch.** Sum the local balance over $t=0,\ldots,N-1$:

$$
\sum_{t=0}^{N-1}S_{t+1}
+
\sum_{t=0}^{N-1}H_t
+
\sum_{t=0}^{N-1}L_t
=
\sum_{t=0}^{N-1}S_t
+
\sum_{t=0}^{N-1}I_t.
$$

The two storage sums contain identical intermediate terms $S_1,\ldots,S_{N-1}$. Cancelling them leaves $S_N$ on the left and $S_0$ on the right. Equivalently, the theorem follows by induction on $N$, appending one local balance at each step. $\square$

**Corollary 4.2 (Useful output plus actual Landauer cost is budget bounded).** For every horizon $N$,

$$
\sum_{t=0}^{N-1}H_t+\sum_{t=0}^{N-1}L_t
\le S_0+\sum_{t=0}^{N-1}I_t.
$$

**Proof sketch.** Rearrange Theorem 4.1 and use $S_N\ge 0$. $\square$

This inequality identifies three legitimate sources for exported energy and computational dissipation: initial stored energy, external injection, and a reduction in terminal storage. If a proposed cycle suppresses all three, the left side must vanish.

## 5. A cardinality-based extraction bound

Exact image cardinalities may be unavailable in a high-level specification. Lemma 2.2 yields a computable lower estimate based on $|A_t|$ and $|B_t|$ alone.

**Theorem 5.1 (Information-adjusted extraction bound).** For every information-accounted process whose output sets $B_t$ are finite, and every horizon $N$,

$$
\sum_{t=0}^{N-1}H_t
+
\sum_{t=0}^{N-1}
\left(\log_2|A_t|-\log_2|B_t|\right)p
\le
S_0+\sum_{t=0}^{N-1}I_t,
$$

where $p=k_BT\ln 2$.

**Proof sketch.** Lemma 2.2 gives

$$
\log_2|A_t|-\log_2|B_t|\le e_t.
$$

Because $p\ge 0$, multiplication preserves the inequality:

$$
\left(\log_2|A_t|-\log_2|B_t|\right)p\le L_t.
$$

Sum over the horizon and combine the resulting inequality with Corollary 4.2. $\square$

The theorem is strongest when $B_t$ closely describes the set of reachable records. If $B_t$ is much larger than the image, the logarithmic gap may underestimate actual erasure. If $|B_t|>|A_t|$, the displayed correction is negative and the bound becomes weaker than the ordinary energy budget. This does not imply negative erasure: actual image-based erased capacity remains nonnegative.

A useful rearrangement isolates harvest:

$$
\sum_{t=0}^{N-1}H_t
\le
S_0+\sum_{t=0}^{N-1}I_t
-
\sum_{t=0}^{N-1}
\left(\log_2|A_t|-\log_2|B_t|\right)p.
$$

When each step genuinely compresses the declared state space, the final sum is nonnegative and directly reduces the maximum useful output.

## 6. Rigidity of an unpowered cycle

We now specialize to the conditions relevant to a closed cyclic harvester.

**Theorem 6.1 (Unpowered cyclic rigidity).** Consider an information-accounted process over a finite horizon $N$. Assume:

1. $k_B>0$ and $T>0$;
2. the process is cyclic in stored energy, $S_N=S_0$;
3. no external energy is supplied, $I_t=0$ for every $0\le t<N$.

Then, for every $0\le t<N$,

$$
H_t=0,
$$

and the finite computation $f_t:A_t\to B_t$ is injective.

**Proof sketch.** Theorem 4.1 and the cyclic and no-input assumptions give

$$
\sum_{t=0}^{N-1}H_t+
\sum_{t=0}^{N-1}L_t=0.
$$

Each $H_t$ is nonnegative. Each $e_t$ is nonnegative because the image of a finite map has at most as many elements as its domain; hence each $L_t=e_tk_BT\ln 2$ is nonnegative. A finite sum of nonnegative terms can vanish only if every term vanishes. Therefore $H_t=0$ and $L_t=0$ for every $t<N$.

Since $k_B>0$, $T>0$, and $\ln 2>0$, the bit price $p$ is strictly positive. Thus $L_t=e_tp=0$ implies $e_t=0$. Theorem 2.3 then implies that every $f_t$ is injective. $\square$

Two aspects deserve emphasis. First, the result is pointwise: it rules out even a single positive harvested step, not only positive net harvest. This follows from the assumed nonnegativity of harvested energy. Second, cyclicity concerns stored energy. A machine that consumes a battery or accumulates unreset memory is not a counterexample; its full state has not returned to the starting condition.

**Corollary 6.2 (Irreversibility requires a budget source).** At positive temperature, if any step before the horizon is noninjective, then at least one of the following must hold: the process receives positive external energy during the horizon, it finishes with less stored energy than it began with, or the claimed local balance omits an energetic channel.

**Proof sketch.** This is the contrapositive of the rigidity mechanism. A noninjective finite map has $e_t>0$, hence $L_t>0$. The finite-horizon identity requires that positive debit to be supplied by external input, decreased storage, or a corresponding correction to the accounting model. $\square$

## 7. Algorithms and numerical examples

### 7.1 Image-based audit

For an explicitly listed deterministic map, the exact erased capacity can be computed without probability theory.

**Algorithm 7.1 (Finite-state information–energy audit).** Given maps encoded as output lists, temperatures, energy injections, useful outputs, and initial storage:

1. For each map, count its input entries $M_t$.
2. Form the set of distinct outputs and count it to obtain $R_t$.
3. Compute $e_t=\log_2(M_t/R_t)$.
4. Compute $L_t=e_tk_BT\ln 2$.
5. Update storage by $S_{t+1}=S_t+I_t-H_t-L_t$.
6. Reject the schedule if any computed storage is negative beyond numerical tolerance.
7. Report cumulative harvest, cumulative Landauer debit, terminal storage, and the conservation residual.

For a map with $M_t$ listed inputs, distinct-output counting takes expected time $O(M_t)$ using hashing and $O(R_t)$ auxiliary memory. Over a horizon, expected time is $O(\sum_tM_t)$.

### 7.2 Example: a six-bit reset

Let a controller map $1024$ inputs to $16$ reached outputs. Then

$$
e=\log_2(1024/16)=6\ \text{bits}.
$$

At $T=300\,\mathrm{K}$ and $k_B=1.380649\times10^{-23}\,\mathrm{J/K}$,

$$
p=k_BT\ln 2\approx2.87098\times10^{-21}\,\mathrm{J/bit},
$$

so

$$
L=6p\approx1.72259\times10^{-20}\,\mathrm{J}.
$$

If such resets occur at rate $10^{15}\,\mathrm{s}^{-1}$, the idealized minimum informational dissipation rate is approximately

$$
1.72259\times10^{-5}\,\mathrm{W}.
$$

### 7.3 Example: reversible relabeling

Let $f$ permute $256$ states. Its image also has $256$ states, so

$$
e=\log_2(256/256)=0.
$$

The ideal Landauer debit is zero at every temperature. The rigidity theorem does not say that a real reversible circuit dissipates no energy; it says that logical erasure contributes no mandatory debit in this ideal accounting.

### 7.4 Example: checking a finite budget

Suppose $S_0=10^{-18}\,\mathrm{J}$, there is no external input, and one six-bit erasure occurs at $300\,\mathrm{K}$. If the process exports $4\times10^{-19}\,\mathrm{J}$, its required terminal storage is

$$
S_1=10^{-18}-4\times10^{-19}-1.72259\times10^{-20}
\approx5.82774\times10^{-19}\,\mathrm{J}.
$$

The output is possible only because the initial reserve decreases. Requiring $S_1=S_0$ would violate the balance unless the useful output and erasure were both zero.

## 8. Applications and interpretation

### 8.1 Vacuum-fluctuation harvesters

A fluctuation-driven controller must correlate internal records with physical outcomes and later prepare itself for reuse. If preparation merges records, the image-based capacity loss contributes to $L_t$. Theorem 5.1 then limits useful export by initial reserve and external injection after an explicit state-space correction. Theorem 6.1 closes the strongest cyclic loophole: no-input return to the same stored energy permits neither useful export nor irreversible control.

The conclusions do not require a claim that the vacuum is static or fluctuation-free. They distinguish microscopic activity from an exploitable thermodynamic gradient. Temporary energy exchange can occur, but a completed closed cycle must restore borrowed energy and account for its records.

### 8.2 Measurement and feedback

Measurement itself can be injective if the apparatus retains both its previous state and the outcome. The thermodynamic issue appears when finite memory is reused. Resetting a record from many possible values to a standard value is many-to-one and therefore has positive erased capacity. Enlarging the controller can postpone erasure by retaining a history, but unbounded history violates finite cyclic return; eventually resetting it restores the debit.

### 8.3 Reversible computing

Theorem 2.3 identifies injectivity as the exact finite-state condition for zero capacity loss. A logically irreversible function may be embedded into an injective map by retaining enough auxiliary information to distinguish colliding inputs. This can reduce the mandatory Landauer cost locally. Nevertheless, the auxiliary state must remain part of the global accounting. Discarding it later is another many-to-one step.

### 8.4 Scope and assumptions

The framework assumes deterministic finite maps, a fixed common temperature, and exact discrete balance. It uses cardinality capacity rather than a probability distribution, so it resembles a worst-case or uniform-capacity measure rather than Shannon entropy under a nonuniform law. It also assumes harvested energy is nonnegative at each step; allowing signed transfers would change the pointwise conclusion while preserving an appropriate net identity.

No specifically quantum postulate is needed for the mathematical bound. This is intentional: the result constrains the macroscopic accounting layer that any proposed implementation must satisfy, whether its microscopic events are classical, quantum, or hybrid. Quantum details may determine the map, transition rates, and accessible reservoirs, but they do not by themselves cancel terminal storage, external input, exported work, or the physical handling of records. The abstraction therefore separates universal bookkeeping from device-dependent dynamics.

The model is therefore an upper-bound framework, not a microscopic theory of a particular apparatus. Its strength is that every conclusion follows from explicit assumptions. A physical proposal may challenge an assumption, but must then supply a replacement balance law rather than simply omit the controller.

## 9. Discussion

The conservation identity and the finite-state lemmas play complementary roles. Conservation alone bounds useful output plus whatever dissipation is acknowledged. Finite information theory supplies a nonnegative, structurally unavoidable debit when a controller merges distinguishable states. Conversely, Landauer accounting alone does not prohibit harvesting from a real external gradient or stored reserve. The combined theorem says exactly what resources are available and how information processing competes with useful output.

The ambient cardinality inequality is especially suited to architecture-level reasoning. It converts a statement about compression—how many distinguishable states enter and how many can leave—into an energetic correction. It remains valid without knowing collision multiplicities. The exact image formula should be preferred when the map is available, because a large nominal output space can conceal severe collapse onto a small reached subset.

Equality in Corollary 4.2 occurs exactly when $S_N=0$ under the exact model. Equality in the cardinality-based Theorem 5.1 additionally requires the cardinality lower bounds to saturate in aggregate; sufficient stepwise conditions are that each image fill its ambient output space whenever its positive bit price matters. A complete classification can distinguish zero-price steps and possible cancellation in weaker signed variants.

The rigidity theorem can also be viewed as an equality characterization for a closed cycle. The total budget available to harvest and erasure is zero. Nonnegativity places the process on an extreme boundary where every admissible debit vanishes. This explains why the result yields injectivity step by step rather than merely a small average information loss.

## 10. Future work

Several extensions arise naturally.

1. **Continuous time.** Replace finite sums by interval integrals and derive the information-adjusted extraction bound from an almost-everywhere differential energy balance.
2. **Nonuniform temperatures.** Give each cycle its own reservoir temperature and prove a weighted cardinality bound with cycle-dependent Landauer prices.
3. **Probabilistic computation.** Replace image-cardinality capacity by Shannon entropy loss under a stochastic channel, connecting the harvesting budget to a genuine data-processing inequality.
4. **Equality characterization.** Classify equality in the finite-horizon bound through zero terminal reserve and saturation of every finite-state compression bound.
5. **Infinite-horizon rates.** Formulate upper bounds on limiting average useful power when cumulative injected energy and cumulative erased information possess asymptotic rates.
6. **Reversible realization.** Couple the rigidity result to reversible embeddings and construct enlarged-state processes whose local computational debit vanishes while explicitly tracking retained history.

## 11. Conclusion

Finite-state control and energy harvesting cannot be placed in separate ledgers. For each step, the exact loss of distinguishable alternatives is $\log_2(|A_t|/|f_t(A_t)|)$ bits, and this loss vanishes precisely for injective computation. Charging it at $k_BT\ln 2$ per bit and telescoping local balances yields an exact finite-horizon conservation theorem. The resulting extraction bounds depend either on actual images or, more coarsely, on input and output cardinalities.

At positive temperature, the closed cyclic case is rigid. With no external input and no net change in stored energy, every useful output is zero and every computational step is reversible. Any proposed cyclic harvester that appears to evade this conclusion must identify which assumption changes: an external energetic source, a depleted reserve, a noncyclic information store, a colder or nonthermal resource, or an omitted channel in the balance. The model thus supplies a precise and reusable standard for evaluating claims of useful extraction from fluctuations.