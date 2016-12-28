/*
 * Copyright (C) 2016 by Scott Murray <scott.murray@konsulko.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef PRESETDATAOBJECT_H
#define PRESETDATAOBJECT_H

#include <QObject>

class PresetDataObject : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(quint32 frequency READ frequency WRITE setFrequency NOTIFY frequencyChanged)
    Q_PROPERTY(quint32 band READ band WRITE setBand NOTIFY bandChanged)

public:
    PresetDataObject(QObject *parent = Q_NULLPTR);
    PresetDataObject(const QString &title, const quint32 &frequency, const quint32 &band, QObject *parent = Q_NULLPTR);

    QString title() const;

    void setTitle(const QString &title);

    quint32 frequency() const;

    void setFrequency(const quint32 &frequency);

    quint32 band() const;

    void setBand(const quint32 &band);

signals:
    void titleChanged();
    void frequencyChanged();
    void bandChanged();

private:
    QString m_title;
    quint32 m_frequency;
    quint32 m_band;
};

#endif // PRESETDATAOBJECT_H
