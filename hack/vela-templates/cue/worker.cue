output: {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	spec: {
		selector: matchLabels: {
			"app.oam.dev/component": context.name
		}

		template: {
			metadata: labels: {
				"app.oam.dev/component": context.name
			}

			spec: {
				containers: [{
					name:  context.name
					image: parameter.image

					if parameter["cmd"] != _|_ {
						command: parameter.cmd
					}

					if parameter["volumes"] != _|_ {
						volumeMounts: [ for v in parameter.volumes {
							{
								mountPath: v.mountPath
								name:      v.name
							}
						}]
					}

					if parameter["volumes"] != _|_ {
						volumeMounts: [ for v in parameter.volumes {
							{
								mountPath: v.mountPath
								name:      v.name
							}}]
					}
				}]

				if parameter["volumes"] != _|_ {
					volumes: [ for v in parameter.volumes {
						{
							name: v.name
							if v.type == "pvc" {
								persistentVolumeClaim: {
									claimName: v.claimName
								}
							}
							if v.type == "configMap" {
								configMap: {
									defaultMode: v.defaultMode
									name:        v.cmName
									if v.items != _|_ {
										items: v.items
									}
								}
							}
							if v.type == "secret" {
								secret: {
									defaultMode: v.defaultMode
									secretName:  v.secretName
									if v.items != _|_ {
										items: v.items
									}
								}
							}
							if v.type == "emptyDir" {
								emptyDir: {
									medium: v.medium
								}
							}
						}}]
				}
			}
		}
	}
}

parameter: {
	// +usage=Which image would you like to use for your service
	// +short=i
	image: string
	// +usage=Commands to run in the container
	cmd?: [...string]
	// +usage=Declare volumes and volumeMounts
	volumes?: [...{
		name:      string
		mountPath: string
		// +usage=Specify volume type, options: "pvc","configMap","secret","emptyDir"
		type: "pvc" | "configMap" | "secret" | "emptyDir"
		if type == "pvc" {
			claimName: string
		}
		if type == "configMap" {
			defaultMode: *420 | int
			cmName:      string
			items?: [...{
				key:  string
				path: string
				mode: *511 | int
			}]
		}
		if type == "secret" {
			defaultMode: *420 | int
			secretName:  string
			items?: [...{
				key:  string
				path: string
				mode: *511 | int
			}]
		}
		if type == "emptyDir" {
			medium: *"" | "Memory"
		}
	}]
}
