/*
 * Copyright 2020 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 *
 */

package com.amazon.opendistroforelasticsearch.notifications.channel

import com.amazon.opendistroforelasticsearch.notifications.settings.EmailChannelType
import com.amazon.opendistroforelasticsearch.notifications.settings.PluginSettings
import org.elasticsearch.common.settings.Settings

object EmailFactory : ChannelProvider {
    const val EMAIL_PREFIX = "mailto:"
    private val channelMap = mapOf(
        EmailChannelType.SMTP.stringValue to EmptyChannel,
        EmailChannelType.SES.stringValue to SesChannel
    )

    override fun getNotificationChannel(settings: Settings, recipient: String): NotificationChannel {
        return channelMap.getOrDefault(PluginSettings.EMAIL_CHANNEL.get(settings), EmptyChannel)
    }
}
