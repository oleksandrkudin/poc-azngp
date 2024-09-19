output "outputs" {
  value = var.deepmerge ? module.deepmerge[0].merged : data.terraform_remote_state.this.outputs
}