/*
 * Copyright (C) 2012,2013 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Michael Terry <michael.terry@canonical.com>
 */

#include "plugin.h"
#include "AccountsService.h"

#include <QDBusMetaType>
#include <QtQml/qqml.h>

static QObject *service_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return new AccountsService();
}

void AccountsServicePlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("AccountsService"));
    qDBusRegisterMetaType<QList<QVariantMap>>();
    qRegisterMetaType<AccountsService::PasswordDisplayHint>("AccountsService::PasswordDisplayHint");
    qmlRegisterSingletonType<AccountsService>(uri, 0, 1, "AccountsService", service_provider);
}
