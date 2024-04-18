variable "name" {
    description = "Name of DynamoDB"
    type = string
    default = "Quotation"
}

variable "hash_key" {
    description = "Name of partition key"
    type = string
    default = "ID"
}

variable "global_index_name" {
    description = "Name of global secondary index"
    type = string
    default = "QuotationIndex"
}

variable "non_key_attributes" {
    description = "Non-key attributes to use in index"
    type = list(string)
    default = []
}