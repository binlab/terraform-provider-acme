# ACME Terraform Provider (Examples)

This branch contains example configurations demonstrating how to work with multiple **ACME** servers (e.g., `production` and `staging`) inside reusable **OpenTofu**(**Terraform**) modules.

Since the official **ACME Terraform** provider (`vancluever/acme`) does not currently support specifying the `server_url` on a per-resource basis, the only way to handle multiple **ACME** servers dynamically is through provider-level configurations -- which can be tricky when using modules.

Below are two examples: a non-working workaround and a partially working workaround (supported only by OpenTofu, not by Terraform).

- [non-working-workaround](./non-working-workaround)

  A simplified example showing an attempt to use multiple **ACME** servers within a single reusable module.
  This approach fails because Terraform forbids modules that define their own local provider configurations from being used with `for_each`, `count`, or `depends_on`.

  ```shell
  tofu init

  Initializing the backend...
  Initializing modules...
  ╷
  │ Error: Module is incompatible with count, for_each, and depends_on
  │
  │   on main.tf line 20, in module "acme":
  │   20:   for_each = local.domains
  │
  │ The module at module.acme is a legacy module which contains its own local provider configurations, and so calls to it may not use the count, for_each, or
  │ depends_on arguments.
  │
  │ If you also control the module "./modules/acme", consider updating this module to instead expect provider configurations to be passed by its caller.
  ╵
  ```

- [working-workaround-opentofu](./working-workaround-opentofu)

  A simplified example that successfully demonstrates using multiple **ACME** servers within a single module only in **OpenTofu**, because **OpenTofu** [supports](https://github.com/opentofu/opentofu/blob/v1.9/CHANGELOG.md#190) `for_each` in provider configurations ([unlike Terraform](https://support.hashicorp.com/hc/en-us/articles/6304194229267-Using-count-or-for-each-in-Provider-Configuration)).
  This setup works but produces a non-critical warning.

  ```shell
  $ tofu init

  Initializing the backend...
  Initializing modules...

  Initializing provider plugins...
  - Reusing previous version of hashicorp/tls from the dependency lock file
  - Reusing previous version of vancluever/acme from the dependency lock file
  - Using previously-installed hashicorp/tls v4.1.0
  - Using previously-installed vancluever/acme v2.36.0

  ╷
  │ Warning: Provider configuration for_each matches module
  │
  │   on main.tf line 19, in module "acme":
  │   19:   for_each = local.acme
  │
  │ This provider configuration uses the same for_each expression as a module, which means that subsequent removal of elements from this collection would cause
  │ a planning error.
  │
  │ OpenTofu relies on a provider instance to destroy resource instances that are associated with it, and so the provider instance must outlive all of its
  │ resource instances by at least one plan/apply round. For removal of instances to succeed in future you must structure the configuration so that the
  │ provider block's for_each expression can produce a superset of the instances of the resources associated with the provider configuration. Refer to the
  │ OpenTofu documentation for specific suggestions.
  │
  │ To destroy this object before removing the provider configuration, consider first performing a targeted destroy:
  │     tofu apply -destroy -target=module.acme
  │
  │ (and one more similar warning elsewhere)
  ╵

  OpenTofu has been successfully initialized!

  You may now begin working with OpenTofu. Try running "tofu plan" to see
  any changes that are required for your infrastructure. All OpenTofu commands
  should now work.

  If you ever set or change modules or backend configuration for OpenTofu,
  rerun this command to reinitialize your working directory. If you forget, other
  commands will detect it and remind you to do so if necessary.
  ```
