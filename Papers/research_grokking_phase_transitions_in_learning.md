# Delayed Generalization in a Width-One ReLU Network and Its Saddle-Node Transition Model

**Aristotle**  
**August 3, 2026**

## Abstract

We present a minimal exact model of grokking-like delayed generalization and pair it with the canonical saddle-node normal form. The learning model is a scalar, width-one, two-layer rectified linear unit network whose time-indexed output is $G_d(t)=\max\{t-d,0\}$ for a prescribed delay $d$. Generalization is defined as strict positivity of this scalar test score. We prove that the score is identically zero for all $t\le d$ and strictly positive for all $t>d$, yielding an exact delayed transition. We then study the vector field $F_\mu(x)=\mu-x^2$ and classify all of its real equilibria: none for $\mu<0$, the unique degenerate equilibrium $x=0$ at $\mu=0$, and exactly two branches $x=\pm\sqrt{\mu}$ for $\mu>0$. Combining these results gives a self-contained threshold-and-bifurcation model in which delayed activation and a qualitative change in equilibrium structure are both explicit. The construction isolates a mechanism rather than asserting universality: the time trajectory is prescribed, and the bifurcation parameter is paired with, rather than derived from, a training loss. We give exact algorithms for evaluating the transition and enumerating equilibria, discuss numerical demonstrations and applications, and identify the additional ingredients required for a dynamical theory of grokking in trained finite-width networks.

## 1. Introduction

Grokking denotes a learning pattern in which useful behavior on unseen data emerges substantially later than successful fitting of observed data. Its most striking feature is temporal separation: a system may exhibit a long plateau in a generalization metric before crossing into a regime of rapid improvement. Such behavior raises at least three distinct mathematical questions. What elementary mechanism can produce a perfectly delayed observable? What does it mean for the change to be a phase transition? How can the appearance of generalization be related to a qualitative change in an underlying dynamical system?

This paper addresses the first two questions in the smallest setting where both can be answered exactly. The network has one scalar input, one rectified hidden unit, and one scalar output. Time itself serves as the input. A hidden bias places the activation threshold at an arbitrary delay $d$. The resulting output is the positive part of $t-d$. Although the preactivation evolves continuously before the threshold, the visible test score is exactly zero. This distinguishes latent motion from observable progress.

The phase-transition component is represented by the standard saddle-node vector field $F_\mu(x)=\mu-x^2$. Its equilibrium set undergoes a complete qualitative change at $\mu=0$: it is empty for negative parameter, contains one degenerate point at criticality, and consists of two square-root branches for positive parameter. The classification is global for this normal form and follows from elementary real algebra.

The two constructions are intentionally paired rather than identified. Time $t$ and bifurcation parameter $\mu$ play different roles, as do network score $G_d(t)$ and state $x$. Consequently, the results do not claim that a particular optimization algorithm generates the trajectory or that a neural loss landscape reduces to the normal form. Instead, they provide an exact baseline against which more mechanistic theories can be measured.

The contributions are:

1. an exact delayed-generalization theorem for a scalar width-one two-layer ReLU network;
2. a complete equilibrium classification of the saddle-node normal form;
3. a combined transition theorem that states both structures without conflating them;
4. linear-time numerical procedures for sampling the delayed score and enumerating equilibria over a parameter grid; and
5. a precise account of the assumptions and extensions needed to connect this minimal model to trained networks.

## 2. Network model and definitions

### 2.1 Rectified linear activation

The rectified linear unit is the function $\rho:\mathbb{R}\to\mathbb{R}$ defined by

$$
\rho(z)=\max\{z,0\}.
$$

Equivalently,

$$
\rho(z)=
\begin{cases}
0, & z\le0,\\
z, & z>0.
\end{cases}
$$

The distinction between the two regimes is exact. Negative and zero preactivations are all mapped to the same visible value, while positive preactivations pass through unchanged.

### 2.2 Scalar two-layer network

**Definition 1 (Scalar width-one two-layer network).** For real input weight $w$, hidden bias $b$, output weight $v$, output bias $c$, and input $x$, define

$$
N_{w,b,v,c}(x)=v\max\{wx+b,0\}+c.
$$

The terminology “two-layer” refers to the hidden affine map and activation followed by the output affine map. Width one means there is a single hidden unit.

### 2.3 Delayed score trajectory

**Definition 2 (Delayed network score).** Fix a real number $d$, called the delay. Select parameters

$$
w=1,\qquad b=-d,\qquad v=1,\qquad c=0,
$$

and use time $t\in\mathbb{R}$ as input. The resulting score is

$$
G_d(t)=N_{1,-d,1,0}(t)=\max\{t-d,0\}.
$$

The parameter $d$ may be any real number. If an application restricts time to nonnegative values, one would normally choose $d\ge0$, but no such restriction is mathematically necessary for the theorem.

**Definition 3 (Generalization criterion).** The network is said to generalize at time $t$ when

$$
G_d(t)>0.
$$

This is a deliberately minimal criterion: $G_d(t)$ should be interpreted as a scalar test score or margin. It is not a claim about population risk or test-set accuracy unless a separate modeling argument identifies the scalar with one of those quantities.

## 3. Exact delayed generalization

We first establish the inactive regime.

**Lemma 1 (Pre-threshold vanishing).** For every $d,t\in\mathbb{R}$, if $t\le d$, then

$$
G_d(t)=0.
$$

**Proof sketch.** The inequality $t\le d$ implies $t-d\le0$. By the definition of the maximum, $\max\{t-d,0\}=0$. Since this maximum is exactly $G_d(t)$, the conclusion follows. $\square$

The strict post-threshold regime is equally direct.

**Lemma 2 (Post-threshold positivity).** For every $d,t\in\mathbb{R}$, if $d<t$, then

$$
G_d(t)=t-d>0.
$$

**Proof sketch.** From $d<t$ one obtains $0<t-d$. The positive argument is selected by the maximum, so $G_d(t)=t-d$, and this quantity is strictly positive. $\square$

Together these statements yield the main network result.

**Theorem 1 (Delayed Generalization Theorem).** For every prescribed delay $d\in\mathbb{R}$, the scalar two-layer network score $G_d(t)=\max\{t-d,0\}$ has the following properties:

$$
\text{for every }t\le d,\quad G_d(t)\not>0,
$$

and

$$
\text{for every }t>d,\quad G_d(t)>0.
$$

Equivalently, the network fails the stated generalization criterion through time $d$, including the critical time itself, and satisfies the criterion at every later time.

**Proof sketch.** Lemma 1 gives $G_d(t)=0$ whenever $t\le d$, which rules out strict positivity. Lemma 2 gives strict positivity whenever $t>d$. These two regions exhaust the real line. $\square$

### 3.1 Interpretation of the delay

The theorem distinguishes the preactivation

$$
a_d(t)=t-d
$$

from the observed score $G_d(t)=\rho(a_d(t))$. The preactivation changes at constant rate throughout time, including throughout the apparent plateau. Nevertheless, all values $a_d(t)\le0$ are collapsed to the score $0$. Thus a flat observable need not imply static latent variables.

The transition is continuous but nonsmooth. In particular, $G_d$ is continuous at $d$, because both one-sided values approach $0$. Its slope, however, changes from $0$ on $t<d$ to $1$ on $t>d$. Generalization as a truth-valued predicate changes sharply even though the real-valued score changes continuously.

The use of strict positivity makes behavior at criticality unambiguous: $G_d(d)=0$, so the system does not generalize at $t=d$. If nonnegative score were used instead, the property would hold at every time and would cease to model a transition. This illustrates why threshold predicates must be chosen carefully.

## 4. Saddle-node normal form

### 4.1 Field and equilibria

**Definition 4 (Saddle-node vector field).** For a real control parameter $\mu$ and real state $x$, define

$$
F_\mu(x)=\mu-x^2.
$$

One may regard this as the right-hand side of the autonomous differential equation

$$
\dot{x}=\mu-x^2.
$$

The equilibrium classification below concerns zeros of the field and does not require solving this differential equation.

**Definition 5 (Equilibrium).** A state $x$ is an equilibrium at parameter $\mu$ if

$$
F_\mu(x)=0.
$$

By substitution, the equilibrium equation is

$$
x^2=\mu.
$$

### 4.2 Negative regime

**Lemma 3 (No negative-parameter equilibria).** If $\mu<0$, then there is no real state $x$ satisfying $F_\mu(x)=0$.

**Proof sketch.** Every real square is nonnegative, so $x^2\ge0$. If $F_\mu(x)=0$, then $x^2=\mu$, contradicting $\mu<0$. $\square$

### 4.3 Critical regime

**Lemma 4 (Unique critical equilibrium).** At $\mu=0$, a real state $x$ is an equilibrium if and only if $x=0$.

**Proof sketch.** The equilibrium equation becomes $x^2=0$. A real square vanishes exactly when its base vanishes, hence $x=0$. Conversely, substitution shows $F_0(0)=0$. $\square$

The critical equilibrium is degenerate in the standard differential sense because

$$
\frac{\partial F_\mu}{\partial x}(0)=-2\cdot0=0.
$$

This derivative observation explains the term “saddle-node normal form,” although the algebraic equilibrium theorem itself uses only the equation $x^2=\mu$.

### 4.4 Positive regime

**Lemma 5 (Positive square-root branches).** If $\mu>0$, then a real state $x$ is an equilibrium if and only if

$$
x=\sqrt{\mu}\quad\text{or}\quad x=-\sqrt{\mu}.
$$

**Proof sketch.** For positive $\mu$, the nonnegative square root satisfies $(\sqrt{\mu})^2=\mu$. If $x$ is an equilibrium, then $x^2=\mu$, and therefore

$$
0=x^2-\mu=x^2-(\sqrt{\mu})^2
=(x-\sqrt{\mu})(x+\sqrt{\mu}).
$$

The zero-product property gives $x=\sqrt{\mu}$ or $x=-\sqrt{\mu}$. Conversely, squaring either candidate gives $\mu$, so both are equilibria. $\square$

We may now state the full classification.

**Theorem 2 (Saddle-Node Equilibrium Classification).** For the field $F_\mu(x)=\mu-x^2$:

1. if $\mu<0$, there are no real equilibria;
2. if $\mu=0$, there is exactly one real equilibrium, $x=0$; and
3. if $\mu>0$, there are exactly two real equilibria, $x=\sqrt{\mu}$ and $x=-\sqrt{\mu}$.

**Proof sketch.** Apply Lemmas 3, 4, and 5 in the negative, zero, and positive parameter regimes, respectively. The trichotomy of real numbers ensures these regimes are exhaustive. $\square$

The equilibrium diagram consists of the two curves $x=\pm\sqrt{\mu}$ for $\mu\ge0$, meeting at $(0,0)$. Their vertical tangent at criticality is reflected by square-root scaling. If the normal form is interpreted as an ODE, the derivative $-2x$ is negative on the positive branch and positive on the negative branch. Thus the positive branch is locally attracting and the negative branch locally repelling. This stability statement is a standard consequence of one-dimensional linearization, but it is contextual rather than required by the core classification.

## 5. Combined threshold and bifurcation result

We next package the delayed score and equilibrium change into one exact statement.

**Theorem 3 (Grokking–Saddle-Node Transition Theorem).** Fix any real delay $d$. Then both of the following hold:

1. For the width-one two-layer ReLU score

$$
G_d(t)=\max\{t-d,0\},
$$

generalization fails for every $t\le d$ and holds for every $t>d$.

2. For the normal-form field

$$
F_\mu(x)=\mu-x^2,
$$

there is no real equilibrium for $\mu<0$, the unique equilibrium at $\mu=0$ is $x=0$, and the equilibria for every $\mu>0$ are exactly $x=\pm\sqrt{\mu}$.

**Proof sketch.** The first assertion is Theorem 1. The three clauses of the second assertion are Theorem 2. Their conjunction gives the result. $\square$

### 5.1 Scope of the coupling

The theorem is a conjunction of two exact mathematical facts. It does not assert an equality between $t$ and $\mu$, between $G_d(t)$ and $x$, or between the ReLU and vector field. One may align critical coordinates by setting $\mu=t-d$, in which case both critical events occur at $t=d$, but this is an interpretive parameterization rather than a derived law.

This distinction matters. A complete dynamical account of learning would begin with a network, data, objective, and optimizer; derive parameter evolution; identify a low-dimensional center direction; and show that the reduced dynamics take the saddle-node form up to controlled remainder terms. The present model supplies the exact endpoint such a reduction might produce, not the reduction itself.

## 6. Algorithms and numerical demonstrations

Although the formulas are closed form, algorithms are useful for visualization, testing, and comparison with observed trajectories.

### 6.1 Delayed-score evaluation

Given a delay $d$ and a list of sample times $t_1,\ldots,t_n$, compute

$$
s_i=\max\{t_i-d,0\}
$$

and the truth-value label

$$
g_i=(s_i>0).
$$

Each sample requires one subtraction, one comparison, and one maximum operation. The total running time is $O(n)$ and the output storage is $O(n)$. If values are streamed rather than retained, auxiliary storage is $O(1)$.

The procedure is exact over real arithmetic and numerically stable in ordinary floating-point arithmetic away from the threshold. Near $t=d$, the classification is sensitive to rounding because strict positivity is itself threshold-sensitive. Implementations should therefore report the score as well as the truth-value label and, when data are noisy, use a separately justified tolerance rather than silently changing the theorem.

### 6.2 Equilibrium enumeration

For each parameter $\mu$ in a list:

- return no equilibria if $\mu<0$;
- return the singleton $[0]$ if $\mu=0$; and
- return $[-\sqrt{\mu},\sqrt{\mu}]$ if $\mu>0$.

This method takes $O(m)$ time for $m$ parameters. It stores at most two states per parameter, so output storage is $O(m)$ and auxiliary storage can again be $O(1)$ in streaming form. The method is preferable to generic root finding for this normal form because it is exhaustive, contains no initialization dependence, and handles the critical case explicitly.

### 6.3 Recommended plots

A first plot should display $G_d(t)$ against $t$, with a vertical line at $t=d$. A second should display the equilibrium branches in the $(\mu,x)$ plane. Side by side, these plots emphasize two different kinds of transition: activation of an observable and change in cardinality of an equilibrium set.

Representative values make the distinction concrete. With $d=3$, times $0$, $2.9$, and $3$ all produce score $0$, while $3.1$ produces $0.1$ and $5$ produces $2$. For the field, $\mu=-1$ yields no equilibrium, $\mu=0$ yields $0$, and $\mu=4$ yields $-2$ and $2$. Substitution verifies each returned state: $4-(\pm2)^2=0$.

## 7. Applications and conceptual consequences

### 7.1 Hidden progress under a nonlinear readout

The ReLU gate demonstrates a generic observational effect. A latent coordinate may evolve smoothly while a readout remains constant on an entire half-line. Similar behavior occurs in thresholded classifiers, dead-zone controllers, switching circuits, and biochemical activation systems. Therefore, a plateau in a metric is not sufficient evidence that the underlying system has stopped changing.

### 7.2 Margin-based classification

If $G_d(t)$ is interpreted as a test margin, then Theorem 1 says that the margin is nonpositive through the delay and positive afterward. In a single-example binary classifier this corresponds to a delayed switch to correct classification. For a finite test set, the natural extension would study the minimum signed margin across examples. Generalization would then occur when all required margins become positive.

### 7.3 Critical scaling

The saddle-node branches obey

$$
|x|=\sqrt{\mu}
$$

for $\mu>0$. This predicts a critical exponent of $1/2$ for branch amplitude in the exact normal form. In applications, approximate square-root scaling can serve as evidence for a saddle-node reduction, provided alternative mechanisms and finite-size effects are considered. It is a diagnostic, not by itself a proof of causal structure.

### 7.4 Continuity versus logical abruptness

The score $G_d$ is continuous, yet the proposition $G_d(t)>0$ changes truth value at $d$. This is a useful caution in interpreting plots of learning metrics. An apparently sudden categorical improvement may arise from a continuous quantity crossing a decision threshold. Conversely, a genuinely discontinuous observable would require a different model.

## 8. Limitations

The model is deliberately minimal. First, time is supplied directly as the network input; no weight dynamics are derived. Second, the network has one hidden unit and one scalar output. Third, the generalization criterion is positivity of one scalar score, with no explicit training set, test set, or probability distribution. Fourth, the delay $d$ is prescribed. Fifth, the saddle-node field is paired with the network transition but is not obtained from its loss landscape.

These limitations prevent several stronger interpretations. The results do not show that gradient descent causes grokking, that regularization is necessary, that arbitrary two-layer networks undergo saddle-node bifurcations, or that real experimental grokking curves have an exact hard threshold. The value of the model is explanatory isolation: each assertion can be read directly from an explicit formula.

## 9. Future work

A first extension is to vector-valued finite-width networks with matrix weights and a finite test set. The scalar positivity condition should be replaced by positivity of a classification margin, ideally the minimum test margin. The challenge is to establish a shared delayed crossing rather than merely coordinatewise activation.

A second extension is to derive the threshold from training dynamics. Gradient flow or weight-decayed gradient descent could produce a time-varying preactivation, and comparison arguments could establish when it crosses zero. This would turn prescribed latent motion into a consequence of optimization.

Third, a train/test separation should be modeled explicitly. One seeks a regime in which training error is already zero while a test loss or negative margin persists until a later threshold. Such a model would more closely match the empirical meaning of grokking.

Fourth, the dynamical theory should include derivatives, standard saddle-node nondegeneracy conditions, local branch existence, and stability exchange. Fifth, robustness results should show persistence of delayed activation and two-branch structure under small perturbations. Finally, a connection theorem should derive the normal form from a reduced neural loss landscape, identifying $\mu$ with an optimizer, regularization, or data-dependent quantity.

## 10. Discussion

A minimal model can be useful without being universal. The delayed ReLU score shows exactly how visible generalization can lag behind latent motion: the nonlinear readout erases the entire precritical region. The saddle-node field shows exactly how a critical parameter can alter the number of available equilibria. Their combination offers a disciplined vocabulary for discussing delay, threshold, degeneracy, and branching.

The principal methodological lesson is to separate observable transitions from dynamical bifurcations. A threshold crossing in a score is not automatically a bifurcation, and a bifurcation in state space is not automatically a theorem about test performance. A mechanistic theory must supply the map between them. By stating both structures in full and marking the missing connection, the present framework makes that research target explicit.

### 10.1 A baseline for model comparison

The exact formulas also define useful null expectations. If an observed score rises before its proposed delay, the hard-gate model is inadequate without noise or perturbation. If inferred branches do not approach one another with square-root geometry, the saddle-node normal form may not be the right local description. Conversely, agreement with either signature supports only that component of the model. This modular use of the results prevents a fit to one plot from being mistaken for evidence about the entire learning mechanism.

## 11. Conclusion

For every real delay $d$, the score of a width-one two-layer ReLU network can remain exactly zero through $d$ and become strictly positive at every later time. For the saddle-node normal form $F_\mu(x)=\mu-x^2$, the equilibrium set changes from empty to a unique degenerate state and then to two square-root branches as $\mu$ crosses zero. Both conclusions follow from elementary inequalities and factorization, and together they form an exact minimal model of delayed activation accompanied by a canonical phase-transition picture.

The construction does not explain all empirical grokking. It identifies a transparent mechanism and the precise mathematical work still needed: derive latent threshold motion from learning, represent genuine train/test separation, and obtain the bifurcation normal form from a neural objective. Those steps would transform the present baseline into a dynamical theory of delayed generalization.