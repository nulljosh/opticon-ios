import Foundation

struct FinanceData: Codable {
    var holdings: [Holding]
    var accounts: [Account]
    var budget: Budget?
    var debt: [DebtItem]
    var goals: [Goal]
    var spending: [SpendingMonth]

    struct Holding: Codable, Identifiable {
        let symbol: String
        let shares: Double
        let costBasis: Double
        let currency: String

        var id: String { symbol }
    }

    struct Account: Codable, Identifiable {
        let name: String
        let type: String
        let balance: Double
        let currency: String

        var id: String { name }

        var typeLabel: String {
            switch type {
            case "chequing": return "Chequing"
            case "investment": return "Investment"
            case "gift": return "Gift Card"
            default: return type.capitalized
            }
        }
    }

    struct Budget: Codable {
        let income: [BudgetLine]
        let expenses: [BudgetLine]

        struct BudgetLine: Codable, Identifiable {
            let name: String
            let amount: Double
            let frequency: String
            let note: String?

            var id: String { name }

            var monthlyAmount: Double {
                switch frequency {
                case "biweekly": return amount * 26 / 12
                case "weekly": return amount * 52 / 12
                case "yearly", "annual": return amount / 12
                default: return amount
                }
            }
        }

        var totalMonthlyIncome: Double {
            income.reduce(0) { $0 + $1.monthlyAmount }
        }

        var totalMonthlyExpenses: Double {
            expenses.reduce(0) { $0 + $1.monthlyAmount }
        }

        var monthlySurplus: Double {
            totalMonthlyIncome - totalMonthlyExpenses
        }
    }

    struct DebtItem: Codable, Identifiable {
        let name: String
        let balance: Double
        let rate: Double
        let minPayment: Double
        let note: String?

        var id: String { name }
    }

    struct Goal: Codable, Identifiable {
        let name: String
        let target: Double
        let saved: Double
        let priority: String
        let deadline: String?
        let note: String?

        var id: String { name }

        var progress: Double {
            guard target > 0 else { return 0 }
            return min(saved / target, 1.0)
        }

        var priorityColor: String {
            switch priority {
            case "high": return "ff3b30"
            case "medium": return "f5a623"
            default: return "34c759"
            }
        }
    }

    struct SpendingMonth: Codable, Identifiable {
        let month: String
        let total: Double
        let categories: [String: Double]

        var id: String { month }

        var sortedCategories: [(key: String, value: Double)] {
            categories.sorted { $0.value > $1.value }
        }
    }
}
