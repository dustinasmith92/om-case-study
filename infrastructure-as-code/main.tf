

variable "files" {
  default = 5
}

resource "local_file" "foo" {
  for_each = toset(["file0.txt", "file2.txt", "file3.txt", "file4.txt"])
  content  = "# Some content for file ${trimprefix(each.key, "file")}"
  filename = each.key
}