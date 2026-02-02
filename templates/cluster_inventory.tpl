%{ for group in groups_pre_children ~}
%{ if length(lookup(groups, group, [])) > 0 ~}
[${group}]
%{ for host in lookup(groups, group, []) ~}
${host}${lookup(host_connection, host, "") != "" ? " ansible_host=${lookup(host_connection, host, "")}" : ""}
%{ endfor }

%{ endif ~}
%{ endfor ~}

[victoria_cluster:children]
%{ if length(cluster_children) == 0 }
# No cluster child groups were generated
%{ else }
%{ for child in cluster_children }
${child}
%{ endfor }
%{ endif }

%{ for group in groups_post_children ~}
%{ if length(lookup(groups, group, [])) > 0 ~}
[${group}]
%{ for host in lookup(groups, group, []) ~}
${host}${lookup(host_connection, host, "") != "" ? " ansible_host=${lookup(host_connection, host, "")}" : ""}
%{ endfor }

%{ endif ~}
%{ endfor ~}
