package com.k8.josdkoperator.customresource;

import io.fabric8.kubernetes.client.CustomResource;
import io.fabric8.kubernetes.model.annotation.ShortNames;
import io.fabric8.kubernetes.model.annotation.Version;

@Version("v1")
@ShortNames("wp")
public class WebPage extends CustomResource<WebPageSpec, WebPageStatus> {
}
