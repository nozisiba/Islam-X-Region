# Islamic Religious Demography and Reproductive Healthcare Access in Africa (2000–2020)  
#### By Nozipho Sibanda   

## Research Overview & Hypotheses  
This research project investigates cross-national disparities in reproductive healthcare access across Africa by evaluating the structural interactions between national religious demography and women's socioeconomic opportunities.

* Primary Research Question: To what extent does a country’s level of Islamic religious demography correlate with variations in reproductive healthcare access across Sub-Saharan and North African contexts?

* Interaction Research Question: Does the relationship between Islamic religious identification and maternal healthcare outcomes vary systematically across differing levels of women’s institutional and structural empowerment?

### Hypotheses  
* __Baseline Hypothesis ($H_1$)__: Higher concentrations of Islamic religious demography correspond to unique structural variations in reproductive health infrastructure, creating distinct cross-national variations in baseline maternal healthcare outcomes.
* **The Moderation Hypothesis ($H_2$)**: The relationship between macro-level religious demography and reproductive health access is conditioned by women's structural development. In high-empowerment contexts, the predictive effect of demographic concentration on health disparities will be significantly mitigated or neutralised.

#Variables and Data Operationalisation  
The dataset features an annual, individual-country-year panel spanning 2000 to 2020, compiled exclusively from source registry archives.  

## Dependent Variable (Y)  
* __Maternal Mortality Ratio (MMR)__: Modelled estimate measured as maternal deaths per 100,000 live births. This serves as the primary macro-indicator for structural reproductive healthcare efficacy and access.
  * Source: World Bank Open Data / World Development Indicators.
## Main Independent Variable ($X$)  
* __Islam Religious Demography__: The percentage of a nation's total population identifying as Muslim. This tracks annual variations in demographic concentration down to individual country-year rows.
   * Source: The Association of Religion Data Archives (ARDA) / Pew Research Centre Panel.
 
## Moderator Variable ($W$)
* __Women's Structural Empowerment Index (WSEI)__: A composite index scaled strictly from $0$ to $1$. It is calculated by taking the arithmetic mean of two normalised gender-disaggregated development vectors:
   1. Educational Attainment: Cumulative percentage of the female population aged 25+ that has completed at least upper secondary education.
   2. Labour Force Participation: Female economic activity rates tracking ages 15–24.
      $$\text{WSEI}_{it} = \frac{\text{Normalised Education}_{it} + \text{Normalised Labor}_{it}}{2}$$
      
      *Source: UNESCO Institute for Statistics / International Labour Organisation (ILO) via World Bank.
 

