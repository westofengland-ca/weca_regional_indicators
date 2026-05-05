The file is at `data/raw/employment_data.xlsx`. Here's what each sheet teaches:

---

### Sheet map to session lessons

| Sheet               | `read_excel()` argument    | What it demonstrates                                                                                                                                                                              |
| ------------------- | -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Employment Data** | *(default — sheet 1)*      | Messy column names (`Area Name` → `area_name` via `clean_names()`); missing values (`None` cells); **wide format** — 5 year-value columns ready for `pivot_longer()`                              |
| **Q4_2024**         | `sheet = "Q4_2024"`        | Reading a named sheet; already clean long-format data; good for visualisation after import                                                                                                        |
| **Data**            | `sheet = "Data", skip = 5` | 5 metadata rows before headers (`Source:`, `Dataset:`, `Downloaded:`, `Notes:`, blank); `Rate (%)` stored as text so `as.numeric()` demo is needed; `None` cells for `drop_na()` / `replace_na()` |
| **Population**      | `sheet = "Population"`     | Population denominators — joins onto `Employment Data` via `area_code` / `LA Code` to compute rates; demonstrates `left_join(by = c("LA Code" = "area_code"))`                                    |

### Exercise sequence using this file

```r
# Part 2 – Import
emp   <- read_excel(here::here("data","raw","employment_data.xlsx"))
q4    <- read_excel(here::here("data","raw","employment_data.xlsx"), sheet = "Q4_2024")
raw   <- read_excel(here::here("data","raw","employment_data.xlsx"), sheet = "Data", skip = 5)
pop   <- read_excel(here::here("data","raw","employment_data.xlsx"), sheet = "Population")

# Part 3 – Clean
emp_clean <- emp |> clean_names()                      # area_name, la_code, x2020_value …
raw_clean <- raw |> clean_names() |>
  mutate(rate = as.numeric(rate_), date = as.Date(date, "%d/%m/%Y")) |>
  drop_na(claimant_count)

# Part 4 – Reshape (Employment Data sheet)
emp_long <- emp_clean |>
  pivot_longer(cols = x2020_value:x2024_value, names_to = "year", values_to = "value") |>
  mutate(year = as.numeric(str_extract(year, "\\d{4}")))

# Part 5 – Join
combined <- emp_clean |>
  left_join(pop, by = c("la_code" = "area_code"))
```
