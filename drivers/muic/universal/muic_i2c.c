/*
 * muic_i2c.c - SM5703 micro USB switch device driver
 *
 * Copyright (C) 2014 Samsung Electronics
 * Thomas Ryu <smilesr.ryu@samsung.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 *
 */

#include <linux/gpio.h>
#include <linux/i2c.h>
#include <linux/interrupt.h>
#include <linux/slab.h>
#include <linux/platform_device.h>
#include <linux/module.h>
#include <linux/delay.h>
#include <linux/host_notify.h>

#include <linux/muic/muic.h>

#if defined(CONFIG_MUIC_NOTIFIER)
#include <linux/muic/muic_notifier.h>
#endif /* CONFIG_MUIC_NOTIFIER */

#if defined (CONFIG_OF)
#include <linux/of_device.h>
#include <linux/of_gpio.h>
#endif /* CONFIG_OF */

#include "muic-internal.h"
#include "muic_debug.h"

int muic_i2c_read_byte(const struct i2c_client *client, u8 command)
{
	int ret;
	int retry = 0;

	ret = i2c_smbus_read_byte_data(client, command);

	while(ret < 0){
		if(retry > 3)
		{
			pr_err("%s: retry count > 3 : failed !!\n", __func__);
			break;
		}

		pr_err("%s:i2c err on reading reg(0x%x), retrying ...\n",
					__func__, command);
		msleep(100);
		ret = i2c_smbus_read_byte_data(client, command);
		retry ++;
	}
#ifdef CONFIG_MUIC_UNIVERSAL_DEBUG
	muic_reg_log(command, ret, retry << 1| READ);
#endif
	return ret;
}

int muic_i2c_write_byte(const struct i2c_client *client,
			u8 command, u8 value)
{
	int ret;
	int retry = 0;

	ret = i2c_smbus_write_byte_data(client, command, value);

	while(ret < 0) {
		if(retry > 3)
		{
			pr_err("%s: retry count > 3 : failed !!\n", __func__);
			break;
		}

		pr_err("%s:i2c err on writing reg(0x%x), retrying ...\n",
					__func__, command);
		msleep(100);
		ret = i2c_smbus_write_byte_data(client, command, value);
		retry ++;
	}
#ifdef CONFIG_MUIC_UNIVERSAL_DEBUG
	muic_reg_log(command, value, retry << 1| WRITE);
#endif
	return ret;
}

int muic_i2c_guaranteed_wbyte(const struct i2c_client *client,
			u8 command, u8 value)
{
	int ret;
	int retry = 0;
	int written;

	ret = muic_i2c_write_byte(client, command, value);
	written = muic_i2c_read_byte(client, command);

	while(written != value){
		pr_err("%s:reg(0x%x): written(0x%x) != value(0x%x)...\n",
					__func__, command, written, value);
		if(retry > 5)
		{
			pr_err("%s: retry count > 5 : failed !!\n", __func__);
			break;
		}
		msleep(100);
		retry ++;
		ret = muic_i2c_write_byte(client, command, value);
		written = muic_i2c_read_byte(client, command);
	}
	return ret;
}

